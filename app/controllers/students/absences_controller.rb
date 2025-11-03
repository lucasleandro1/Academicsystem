class Students::AbsencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    # Verificar se o usuário tem uma turma
    unless current_user.classroom
      redirect_to students_root_path, alert: "Você não está matriculado em nenhuma turma."
      return
    end

    # Buscar disciplinas através dos horários da turma do aluno
    @subjects = current_user.classroom.class_schedules.includes(:subject).map(&:subject).uniq

    # Buscar todas as ausências do aluno (antes dos filtros)
    all_absences = current_user.student_absences.includes(:subject)

    # Buscar ausências do aluno para exibição (com filtros)
    @absences = all_absences.order(date: :desc)

    # Aplicar filtros se fornecidos
    if params[:subject_id].present?
      @absences = @absences.where(subject_id: params[:subject_id])
    end

    if params[:period].present?
      case params[:period]
      when "current_month"
        @absences = @absences.where(date: Date.current.beginning_of_month..Date.current.end_of_month)
      when "last_month"
        last_month = Date.current.last_month
        @absences = @absences.where(date: last_month.beginning_of_month..last_month.end_of_month)
      when "current_quarter"
        # Aproximadamente 3 meses (trimestre)
        quarter_start = 3.months.ago.beginning_of_month
        @absences = @absences.where(date: quarter_start..Date.current.end_of_month)
      when "current_semester"
        # Aproximadamente 6 meses (semestre)
        semester_start = 6.months.ago.beginning_of_month
        @absences = @absences.where(date: semester_start..Date.current.end_of_month)
      when "current_year"
        @absences = @absences.where(date: Date.current.beginning_of_year..Date.current.end_of_year)
      end
    end

    if params[:status].present?
      case params[:status]
      when "justified"
        @absences = @absences.where(justified: true)
      when "unjustified"
        @absences = @absences.where(justified: false)
      end
    end

    # Calcular informações de frequência para cada disciplina (usando todas as ausências, não filtradas)
    @attendance_data = {}
    @subjects.each do |subject|
      # Contar horários semanais desta disciplina para a turma do aluno
      weekly_classes = current_user.classroom.class_schedules.where(subject: subject).count

      # Calcular semanas passadas desde início do ano letivo (aproximadamente)
      year_start = Date.new(Date.current.year, 2, 1) # Assumindo que o ano letivo começa em fevereiro
      weeks_passed = [ (Date.current - year_start).to_i / 7, 1 ].max

      # Total de aulas até agora
      total_classes = weekly_classes * weeks_passed

      # Ausências desta disciplina (todas, não filtradas)
      subject_absences = all_absences.where(subject: subject).count

      # Taxa de presença
      attendance_rate = total_classes > 0 ? ((total_classes - subject_absences).to_f / total_classes * 100).round(1) : 100

      @attendance_data[subject.id] = {
        weekly_classes: weekly_classes,
        total_classes: total_classes,
        absences: subject_absences,
        attendance_rate: attendance_rate,
        present_classes: [ total_classes - subject_absences, 0 ].max
      }
    end

    # Resumo de faltas por disciplina (apenas das disciplinas dos horários da turma)
    subject_ids = @subjects.pluck(:id)
    @absence_summary = @absences.where(subject_id: subject_ids)
                                .group(:subject_id).group(:justified).count
                                .each_with_object({}) do |((subject_id, justified), count), hash|
      hash[subject_id] ||= { total: 0, justified: 0, unjustified: 0 }
      hash[subject_id][:total] += count
      if justified
        hash[subject_id][:justified] += count
      else
        hash[subject_id][:unjustified] += count
      end
    end

    # Calcular faltas por mês para cada disciplina
    @monthly_absences = {}
    @subjects.each do |subject|
      monthly_data = []
      total_absences = 0

      # Últimos 12 meses
      (11.downto(0)).each do |months_ago|
        month_start = months_ago.months.ago.beginning_of_month
        month_end = months_ago.months.ago.end_of_month
        month_name = %w[Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro][month_start.month - 1]

        absences_count = all_absences.where(subject: subject)
                                   .where(date: month_start..month_end)
                                   .count

        monthly_data << {
          name: month_name,
          count: absences_count,
          date: month_start
        }
        total_absences += absences_count
      end

      @monthly_absences[subject.id] = {
        monthly_data: monthly_data,
        total_absences: total_absences
      }
    end
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
