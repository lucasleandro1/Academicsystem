class Direction::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]

  def index
    @school = current_user.school
    @students = User.joins(student_enrollments: :classroom)
                   .where(classrooms: { school_id: @school.id }, user_type: "student")
                   .includes(:student_enrollments)
                   .distinct

    # Filtros
    if params[:search].present?
      @students = @students.where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR users.registration_number ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:classroom_id].present?
      @students = @students.joins(:student_enrollments).where(enrollments: { classroom_id: params[:classroom_id] })
    end

    if params[:status].present?
      @students = @students.joins(:student_enrollments).where(enrollments: { status: params[:status] })
    end

    @students = @students.order(:first_name, :last_name)
    @classrooms = Classroom.where(school: @school)
  end

  def show
    @enrollments = @student.student_enrollments.where(school: current_user.school).includes(:classroom)
    @grades = Grade.where(user: @student).includes(:subject, :activity).order(created_at: :desc).limit(10)
    @absences = Absence.where(user: @student).order(date: :desc).limit(10)
    @occurrences = Occurrence.where(user: @student).order(date: :desc).limit(5)
  end

  def new
    @user = User.new
    @classrooms = Classroom.where(school: current_user.school)
  end

  def edit
    @classrooms = Classroom.where(school: current_user.school)
  end

  def create
    @user = User.new(user_params.merge(user_type: :student, school_id: current_user.school.id))

    if @user.save
      # Criar matrícula se uma turma foi selecionada
      if params[:user][:classroom_id].present?
        Enrollment.create!(
          user: @user,
          classroom_id: params[:user][:classroom_id],
          school: current_user.school,
          enrollment_date: Date.current,
          status: "active"
        )
      end

      redirect_to direction_students_path, notice: "Aluno criado com sucesso."
    else
      @classrooms = Classroom.where(school: current_user.school)
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to direction_student_path(@user), notice: "Aluno atualizado com sucesso."
    else
      @classrooms = Classroom.where(school: current_user.school)
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to direction_students_path, notice: "Aluno removido com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_student
    @user = User.joins(:student_enrollments)
               .where(enrollments: { school_id: current_user.school.id }, user_type: "student", id: params[:id])
               .first

    unless @user
      redirect_to direction_students_path, alert: "Aluno não encontrado."
    end

    @student = @user
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name,
      :birth_date, :guardian_name, :phone, :registration_number, :active
    )
  end
end
