class Teachers::GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_grade, only: [ :show, :edit, :update, :destroy ]

  def index
    @subjects = current_user.teacher_subjects.includes(:classroom)

    # Obter turmas disponíveis para o professor através de class_schedules
    @classrooms = Classroom.joins(class_schedules: :subject)
                          .where(subjects: { user_id: current_user.id })
                          .distinct
                          .order(:name)

    # Filtrar por turma se especificada
    if params[:classroom_id].present?
      @selected_classroom = @classrooms.find(params[:classroom_id])

      # Filtrar notas de alunos que pertencem à turma selecionada
      student_ids = User.where(classroom_id: @selected_classroom.id, user_type: "student").pluck(:id)
      @grades = Grade.joins(:subject)
                    .where(subjects: { user_id: current_user.id })
                    .where(user_id: student_ids)
                    .includes(:student, :subject)
                    .order(assessment_date: :desc, bimester: :desc, created_at: :desc)
                    .page(params[:page])
                    .per(20)
    else
      @grades = Grade.joins(:subject)
                    .where(subjects: { user_id: current_user.id })
                    .includes(:student, subject: { class_schedules: :classroom })
                    .order(assessment_date: :desc, bimester: :desc, created_at: :desc)
                    .page(params[:page])
                    .per(20)
    end
  end

  def show
  end

  def new
    @grade = Grade.new(
      max_value: 10.0,
      assessment_date: Date.current,
      school_id: current_user.school_id
    )

    # Agrupar disciplinas por nome para o seletor inicial
    all_subjects = current_user.teacher_subjects.includes(:classroom)
    @subjects_grouped = all_subjects.group_by(&:name).map do |name, subjects|
      representative_subject = subjects.first
      representative_subject.define_singleton_method(:grouped_subjects) { subjects }
      representative_subject
    end

    # Obter parâmetros da URL ou do formulário
    @selected_subject_name = params[:subject_name] || params.dig(:grade, :subject_name)
    @selected_classroom_id = params[:classroom_id] || params.dig(:grade, :classroom_id)
    @selected_user_id = params[:user_id] || params.dig(:grade, :user_id)

    # Carregar dados baseados nos parâmetros
    load_form_data

    # Se há dados de erro de validação, preservar valores do formulário
    if params[:grade].present?
      @grade.assign_attributes(grade_params.except(:subject_name, :classroom_id))
      @selected_subject_name ||= params[:grade][:subject_name]
      @selected_classroom_id ||= params[:grade][:classroom_id]
      @selected_user_id ||= params[:grade][:user_id]
    end
  end

  def edit
    @subjects = current_user.teacher_subjects
    @students = @grade.subject.students
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

    if subject_name.present? && classroom_id.present?
      classroom = Classroom.find(classroom_id)
      subject_instances = current_user.teacher_subjects.select { |s| s.name == subject_name }
      subject = subject_instances.find { |s| s.available_classrooms.include?(classroom) }

      if subject
        students = subject.students_from_classroom(classroom_id)
        render json: {
          students: students.map { |s| { id: s.id, name: s.full_name } }
        }
      else
        render json: { students: [] }
      end
    else
      render json: { students: [] }
    end
  end

  def create
    # Encontrar a disciplina correta baseada no nome e turma
    subject_name = params[:grade][:subject_name]
    classroom_id = params[:grade][:classroom_id]

    if subject_name.present? && classroom_id.present?
      classroom = Classroom.find(classroom_id)
      subject_instances = current_user.teacher_subjects.select { |s| s.name == subject_name }
      subject = subject_instances.find { |s| s.available_classrooms.include?(classroom) }

      if subject
        # Verificar se a nota já existe para evitar duplicatas
        existing_grade = Grade.find_by(
          subject_id: subject.id,
          user_id: params[:grade][:user_id],
          bimester: params[:grade][:bimester],
          grade_type: params[:grade][:grade_type],
          assessment_name: params[:grade][:assessment_name]
        )

        if existing_grade
          redirect_to teachers_grades_path, alert: "Esta nota já foi cadastrada anteriormente."
          return
        end

        # Criar os parâmetros corretos com o subject_id encontrado
        grade_params_with_subject = grade_params.except(:subject_name, :classroom_id).merge(
          subject_id: subject.id,
          school_id: current_user.school_id
        )
        @grade = Grade.new(grade_params_with_subject)

        if @grade.save
          redirect_to teachers_grades_path, notice: "Nota registrada com sucesso."
          return
        end
      else
        @grade = Grade.new(grade_params.except(:subject_name, :classroom_id).merge(school_id: current_user.school_id))
        @grade.errors.add(:subject_id, "não encontrada para esta turma")
      end
    else
      @grade = Grade.new(grade_params.except(:subject_name, :classroom_id).merge(school_id: current_user.school_id))
      @grade.errors.add(:base, "Disciplina e turma devem ser selecionadas")
    end

    # Se chegou até aqui, houve erro - recarregar dados para o formulário
    all_subjects = current_user.teacher_subjects.includes(:classroom)
    @subjects_grouped = all_subjects.group_by(&:name).map do |name, subjects|
      representative_subject = subjects.first
      representative_subject.define_singleton_method(:grouped_subjects) { subjects }
      representative_subject.define_singleton_method(:all_classrooms) do
        subjects.map(&:available_classrooms).flatten.uniq
      end
      representative_subject
    end

    @selected_subject_name = subject_name
    @subject_instances = all_subjects.select { |s| s.name == subject_name } if subject_name
    @classrooms = @subject_instances&.map(&:available_classrooms)&.flatten&.uniq || []
    @selected_classroom = classroom_id.present? ? Classroom.find(classroom_id) : nil
    @students = @selected_classroom && @subject_instances ?
                @subject_instances.find { |s| s.available_classrooms.include?(@selected_classroom) }&.students_from_classroom(@selected_classroom.id) || [] :
                []

    render :new
  end

  def update
    if @grade.update(grade_params)
      classroom_id = @grade.subject.classroom_id
      redirect_to teachers_grades_path(classroom_id: classroom_id), notice: "Nota atualizada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = @grade.subject.students
      render :edit
    end
  end

  def destroy
    classroom_id = @grade.subject.classroom_id
    @grade.destroy
    redirect_to teachers_grades_path(classroom_id: classroom_id), notice: "Nota removida com sucesso."
  end

  private

  def set_grade
    @grade = Grade.joins(:subject).where(subjects: { user_id: current_user.id }).find(params[:id])
  end

  def load_form_data
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

  def grade_params
    params.require(:grade).permit(:subject_id, :subject_name, :classroom_id, :user_id, :bimester, :value, :max_value, :assessment_name, :assessment_date, :grade_type)
  end
end
