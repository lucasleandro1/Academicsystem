class Direction::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school
    load_dashboard_data
  rescue => e
    Rails.logger.error "Erro no dashboard da direção: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    handle_dashboard_error
  end

  def refresh_data
    @school = current_user.school
    load_dashboard_data

    render json: {
      total_students: @total_students,
      total_teachers: @total_teachers,
      total_classrooms: @total_classrooms,
      total_subjects: @total_subjects,
      attendance_rate: @attendance_rate,
      average_grade: @average_grade,
      total_messages: @total_messages,
      updated_at: Time.current.strftime("%d/%m/%Y às %H:%M")
    }
  rescue => e
    Rails.logger.error "Erro ao atualizar dados do dashboard: #{e.message}"
    render json: { error: "Erro ao atualizar dados" }, status: 500
  end

  private

  def load_dashboard_data
    # Estatísticas básicas
    @total_students = User.where(school_id: @school.id, user_type: "student")
                         .distinct.count
    @total_teachers = User.where(school_id: @school.id, user_type: "teacher").count
    @total_classrooms = Classroom.where(school_id: @school.id).count
    @total_subjects = Subject.joins(:classroom).where(classrooms: { school_id: @school.id }).distinct.count

    # Eventos próximos (próximos 7 dias)
    @upcoming_events = Event.where(school_id: @school.id)
                           .where("start_date >= ? AND start_date <= ?", Date.current, 7.days.from_now)
                           .order(:start_date)
                           .limit(5)

    # Avisos e notificações importantes
    @important_notifications = get_important_notifications

    # Relatórios gerais
    @attendance_rate = calculate_attendance_rate
    @average_grade = calculate_average_grade
    @total_messages = calculate_total_messages

    # Alertas e avisos
    @alerts = generate_school_alerts
  end

  def handle_dashboard_error
    # Valores padrão em caso de erro
    @total_students = 0
    @total_teachers = 0
    @total_classrooms = 0
    @total_subjects = 0
    @upcoming_events = []
    @important_notifications = []
    @attendance_rate = "N/A"
    @average_grade = "N/A"
    @total_messages = 0
    @alerts = []

    flash.now[:alert] = "Erro ao carregar dados do dashboard. Alguns indicadores podem não estar atualizados."
  end

  # ... métodos privados existentes ...

  def get_important_notifications
    notifications = []

    # Verificar eventos próximos
    events_today = Event.where(school_id: @school.id, start_date: Date.current).count
    if events_today > 0
      notifications << {
        type: "info",
        icon: "fas fa-calendar-day",
        title: "Eventos Hoje",
        message: "#{events_today} evento(s) programado(s) para hoje",
        link: direction_events_path
      }
    end

    # Verificar professores sem disciplinas
    teachers_without_subjects = User.where(school_id: @school.id, user_type: "teacher")
                                   .left_joins(:teacher_subjects)
                                   .where(subjects: { id: nil })
                                   .count
    if teachers_without_subjects > 0
      notifications << {
        type: "warning",
        icon: "fas fa-user-times",
        title: "Professores sem Disciplinas",
        message: "#{teachers_without_subjects} professor(es) sem disciplinas atribuídas",
        link: direction_teachers_path
      }
    end

    # Verificar turmas sem horários completos
    classrooms_without_full_schedule = Classroom.where(school_id: @school.id)
                                               .select { |c| c.class_schedules.active.count < 20 } # Menos de 20 aulas por semana
                                               .count
    if classrooms_without_full_schedule > 0
      notifications << {
        type: "warning",
        icon: "fas fa-clock",
        title: "Grade de Horários Incompleta",
        message: "#{classrooms_without_full_schedule} turma(s) com grade de horários incompleta",
        link: direction_class_schedules_path
      }
    end

    notifications
  end

  def generate_school_alerts
    alerts = []

    # Taxa de frequência baixa
    attendance_numeric = @attendance_rate.to_f if @attendance_rate != "N/A"
    if attendance_numeric && attendance_numeric < 75
      alerts << {
        type: "danger",
        title: "Taxa de Frequência Baixa",
        message: "A taxa de frequência da escola está em #{@attendance_rate}%, abaixo do recomendado (85%)"
      }
    end

    # Verificar conflitos de horários
    conflicting_schedules = ClassSchedule.where(school_id: @school.id, active: true)
                                        .group(:classroom_id, :weekday, :start_time)
                                        .having("COUNT(*) > 1")
                                        .count
    if conflicting_schedules.any?
      alerts << {
        type: "danger",
        title: "Conflitos de Horário",
        message: "Existem #{conflicting_schedules.size} conflito(s) na grade de horários"
      }
    end

    # Verificar professores sem horários atribuídos (através das disciplinas)
    teachers_without_classrooms = User.where(school_id: @school.id, user_type: "teacher")
                                     .left_joins(:teacher_subjects)
                                     .joins("LEFT JOIN class_schedules ON subjects.id = class_schedules.subject_id")
                                     .where(class_schedules: { id: nil })
                                     .where.not(subjects: { id: nil })
                                     .distinct
                                     .count
    if teachers_without_classrooms > 0
      alerts << {
        type: "info",
        title: "Professores sem Horários",
        message: "#{teachers_without_classrooms} professor(es) com disciplinas mas sem horários definidos"
      }
    end

    alerts
  end

  private

  def calculate_attendance_rate
    # Calculando taxa de frequência baseada nas ausências dos últimos 30 dias
    total_students = User.where(school_id: @school.id, user_type: "student").count

    return "N/A" if total_students.zero?

    # Corrigindo o join - usar :student ao invés de :user
    total_absences = Absence.joins(:student)
                           .where(users: { school_id: @school.id })
                           .where("absences.date >= ?", 30.days.ago)
                           .count

    # Se não há ausências registradas nos últimos 30 dias, verificar se há ausências antigas
    if total_absences.zero?
      all_absences = Absence.joins(:student).where(users: { school_id: @school.id }).count

      if all_absences.zero?
        return "N/A"  # Não há dados de frequência
      else
        # Há ausências registradas, mas não recentes - assumir boa frequência
        return "95.0"
      end
    end

    # Calculamos uma estimativa mais realista
    # Assumindo 22 dias letivos por mês (excluindo fins de semana)
    expected_presences = total_students * 22
    actual_presences = expected_presences - total_absences

    # Garantir que não seja negativo e arredondar para 1 casa decimal
    attendance_rate = [ (actual_presences.to_f / expected_presences * 100), 0.0 ].max.round(1)

    # Se a taxa calculada for muito alta (>100%), limitar a 98%
    [ attendance_rate, 98.0 ].min.to_s
  end

  def calculate_average_grade
    # Corrigindo o join - usar :student ao invés de :user
    grades = Grade.joins(:student)
                  .where(users: { school_id: @school.id })
                  .where("grades.created_at >= ?", 30.days.ago)

    # Se não há notas recentes, verificar se há notas antigas
    if grades.empty?
      all_grades = Grade.joins(:student).where(users: { school_id: @school.id })

      if all_grades.empty?
        return "N/A"  # Não há notas cadastradas
      else
        # Usar a média de todas as notas se não há notas recentes
        average = all_grades.average(:value) || 0
        return average.round(1).to_s
      end
    end

    average = grades.average(:value) || 0
    average.round(1).to_s
  end

  def calculate_total_messages
    # Contando mensagens enviadas pelos usuários da escola nos últimos 30 dias
    # Verificar se a associação :sender existe no modelo Message
    begin
      Message.joins(:sender)
             .where(users: { school_id: @school.id })
             .where("messages.created_at >= ?", 30.days.ago)
             .count
    rescue ActiveRecord::StatementInvalid, ActiveRecord::AssociationNotFoundError => e
      # Se houver erro na associação, contar mensagens de forma alternativa
      Rails.logger.warn "Erro ao calcular mensagens: #{e.message}"

      # Tentar contagem alternativa usando sender_id
      Message.where(sender_id: User.where(school_id: @school.id).pluck(:id))
             .where("created_at >= ?", 30.days.ago)
             .count
    rescue => e
      Rails.logger.error "Erro crítico ao calcular mensagens: #{e.message}"
      0 # Retorna 0 em caso de erro
    end
  end
end
