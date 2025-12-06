class Teachers::AbsencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_absence, only: [ :show, :edit, :update, :destroy ]

  def index
    # Manter a funcionalidade original do index para não quebrar outras partes
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @selected_subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : @subjects.first
    @absences = @selected_subject&.absences&.includes(:student) || Absence.none
    @students = @selected_subject&.students || []
  end

  def attendance
    # Agrupar disciplinas por nome para evitar duplicação
    all_subjects = current_user.teacher_subjects.includes(:classroom)
    @subjects_grouped = all_subjects.group_by(&:name).map do |name, subjects|
      representative_subject = subjects.first
      representative_subject.define_singleton_method(:grouped_subjects) { subjects }
      representative_subject
    end

    # Obter parâmetros
    @selected_subject_name = params[:subject_name]
    @selected_classroom_id = params[:classroom_id]
    @date = params[:date] ? Date.parse(params[:date]) : Date.current

    # Carregar dados baseados nos parâmetros
    load_attendance_data

    # Buscar faltas já registradas para esta data, disciplina e turma
    if @current_subject && @selected_classroom && @date
      existing_absences = @current_subject.absences.where(
        date: @date,
        user_id: @students.pluck(:id)
      )
      @absent_student_ids = existing_absences.pluck(:user_id)
    else
      @absent_student_ids = []
    end
  end

  def get_classrooms
    subject_name = params[:subject_name]

    if subject_name.present?
      subject_instances = current_user.teacher_subjects.select { |s| s.name == subject_name }
      classrooms = subject_instances.map(&:available_classrooms).flatten.uniq

      render json: {
        classrooms: classrooms.map { |c| { id: c.id, name: c.name } }
      }
    else
      render json: { classrooms: [] }
    end
  end

  def get_students
    subject_name = params[:subject_name]
    classroom_id = params[:classroom_id]
    date = params[:date] ? Date.parse(params[:date]) : Date.current

    if subject_name.present? && classroom_id.present?
      classroom = Classroom.find(classroom_id)
      subject_instances = current_user.teacher_subjects.select { |s| s.name == subject_name }
      subject = subject_instances.find { |s| s.available_classrooms.include?(classroom) }

      if subject
        students = subject.students_from_classroom(classroom_id)

        # Buscar faltas já registradas para esta data
        existing_absences = subject.absences.where(
          date: date,
          user_id: students.pluck(:id)
        )
        absent_student_ids = existing_absences.pluck(:user_id)

        render json: {
          students: students.map { |s| {
            id: s.id,
            name: s.full_name,
            email: s.email,
            is_absent: absent_student_ids.include?(s.id)
          } },
          date: date.strftime("%d/%m/%Y")
        }
      else
        render json: { students: [], date: date.strftime("%d/%m/%Y") }
      end
    else
      render json: { students: [], date: date.strftime("%d/%m/%Y") }
    end
  end

  def bulk_create
    begin
      @selected_classroom = Classroom.find(params[:classroom_id])
      @date = Date.parse(params[:date])

      # Encontrar a instância correta da disciplina para esta turma
      subject_name = params[:subject_name]
      subject_instances = current_user.teacher_subjects.select { |s| s.name == subject_name }
      @subject = subject_instances.find { |s| s.available_classrooms.include?(@selected_classroom) }

      unless @subject
        redirect_to attendance_teachers_absences_path, alert: "Disciplina não encontrada para esta turma."
        return
      end

      @students = @subject.students_from_classroom(@selected_classroom.id)

      # Obter lista de alunos faltosos
      # Remover valores vazios e duplicados
      absent_student_ids = (params[:absent_students] || []).reject(&:blank?).uniq
      
      # Log para debug
      Rails.logger.info "=== BULK CREATE ABSENCES ==="
      Rails.logger.info "Subject: #{@subject.name} (ID: #{@subject.id})"
      Rails.logger.info "Classroom: #{@selected_classroom.name} (ID: #{@selected_classroom.id})"
      Rails.logger.info "Date: #{@date}"
      Rails.logger.info "Absent students IDs: #{absent_student_ids.inspect}"
      Rails.logger.info "Total students in classroom: #{@students.count}"

      # Limpar faltas existentes para esta data/disciplina/turma
      existing_absences = @subject.absences.where(
        date: @date,
        user_id: @students.pluck(:id)
      )
      deleted_count = existing_absences.count
      existing_absences.destroy_all

      # Criar novas faltas
      success_count = 0
      errors = []
      absent_student_ids.each do |student_id|
        student = @students.find_by(id: student_id.to_i)
        if student
          absence = @subject.absences.build(
            user_id: student_id,
            date: @date,
            justified: false
          )
          if absence.save
            success_count += 1
            Rails.logger.info "Absence created for student #{student.full_name} (ID: #{student_id})"
          else
            error_msg = "Erro ao salvar falta do aluno #{student.full_name} (ID #{student_id}): #{absence.errors.full_messages.join(', ')}"
            errors << error_msg
            Rails.logger.error error_msg
          end
        else
          Rails.logger.warn "Student ID #{student_id} not found in classroom"
        end
      end

      # Log dos erros se houver
      if errors.any?
        Rails.logger.error "=== ERRORS IN BULK CREATE ==="
        errors.each { |e| Rails.logger.error e }
        redirect_to attendance_teachers_absences_path(
          subject_name: subject_name,
          classroom_id: @selected_classroom.id,
          date: @date
        ), alert: "Erro ao salvar algumas faltas: #{errors.join('; ')}"
        return
      end

      # Mensagem mais informativa
      present_count = @students.count - success_count
      if absent_student_ids.empty?
        message = "Chamada registrada! Todos os #{@students.count} alunos marcados como presentes."
      else
        message = "Chamada registrada! #{present_count} presente(s), #{success_count} ausente(s)."
        message += " (#{deleted_count} registro(s) anterior(es) removido(s))" if deleted_count > 0
      end
      
      redirect_to attendance_teachers_absences_path(
        subject_name: subject_name,
        classroom_id: @selected_classroom.id,
        date: @date
      ), notice: message
    rescue => e
      Rails.logger.error "=== EXCEPTION IN BULK CREATE ==="
      Rails.logger.error "Error: #{e.class.name} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to attendance_teachers_absences_path, alert: "Erro ao processar a chamada: #{e.message}"
    end
  end

  def show
  end

  def new
    @absence = Absence.new
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
    @classrooms = @subject&.available_classrooms || []
    @selected_classroom = params[:classroom_id] ? Classroom.find(params[:classroom_id]) : nil
    @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []

    # Preservar dados do form se houver erro de validação
    if params[:absence]
      @absence.assign_attributes(absence_params)
      # Recuperar classroom_id dos parâmetros se disponível
      @selected_classroom = params[:absence][:classroom_id].present? ? Classroom.find(params[:absence][:classroom_id]) : @selected_classroom
      @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : @students
    end
  end

  def edit
    @subjects = current_user.teacher_subjects
    @students = @absence.subject.students
  end

  def create
    @absence = Absence.new(absence_params)

    if @absence.save
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta registrada com sucesso."
    else
      @subjects = current_user.teacher_subjects.includes(:classroom)
      @subject = Subject.find(absence_params[:subject_id]) if absence_params[:subject_id]
      @classrooms = @subject&.available_classrooms || []
      # Obter classroom_id dos parâmetros da requisição, não do model absence
      @selected_classroom = params[:absence][:classroom_id].present? ? Classroom.find(params[:absence][:classroom_id]) : nil
      @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []
      render :new
    end
  end

  def update
    if @absence.update(absence_params)
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta atualizada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = @absence.subject.students
      render :edit
    end
  end

  def destroy
    subject_id = @absence.subject_id
    @absence.destroy
    redirect_to teachers_absences_path(subject_id: subject_id), notice: "Falta removida com sucesso."
  end

  private

  def load_attendance_data
    # Inicializar variáveis vazias
    @classrooms = []
    @students = []
    @subject_instances = []
    @current_subject = nil
    @selected_classroom = nil

    # Carregar turmas se disciplina foi selecionada
    if @selected_subject_name.present?
      all_subjects = current_user.teacher_subjects.includes(:classroom)
      @subject_instances = all_subjects.select { |s| s.name == @selected_subject_name }
      @classrooms = @subject_instances.map(&:available_classrooms).flatten.uniq

      # Carregar alunos se turma foi selecionada
      if @selected_classroom_id.present? && @classrooms.any? { |c| c.id.to_s == @selected_classroom_id.to_s }
        @selected_classroom = @classrooms.find { |c| c.id.to_s == @selected_classroom_id.to_s }
        @current_subject = @subject_instances.find { |s| s.available_classrooms.include?(@selected_classroom) }
        @students = @current_subject&.students_from_classroom(@selected_classroom_id) || []
      end
    end
  end

  def set_absence
    @absence = Absence.joins(:subject).where(subjects: { user_id: current_user.id }).find(params[:id])
  end

  def absence_params
    params.require(:absence).permit(:subject_id, :user_id, :date, :justified, :justification)
  end
end
