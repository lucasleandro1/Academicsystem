class Direction::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_student, only: [ :show, :edit, :update, :destroy ]

  def index
    @school = current_user.school
    @students = User.where(school_id: @school.id, user_type: "student")
                   .includes(:classroom)
                   .distinct

    # Filtros
    if params[:search].present?
      @students = @students.where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:classroom_id].present?
      @students = @students.where(classroom_id: params[:classroom_id])
    end

    @students = @students.order(:first_name, :last_name)
    @classrooms = Classroom.where(school: @school)
  end

  def show
    @grades = Grade.where(user_id: @student.id).includes(:subject).order(created_at: :desc).limit(10)
    @absences = Absence.where(user_id: @student.id).order(date: :desc).limit(10)
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

  def set_student
    @user = User.where(school_id: current_user.school.id, user_type: "student", id: params[:id])
               .first

    unless @user
      redirect_to direction_students_path, alert: "Aluno não encontrado."
    end

    @student = @user
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name,
      :birth_date, :guardian_name, :phone, :classroom_id
    )
  end
end
