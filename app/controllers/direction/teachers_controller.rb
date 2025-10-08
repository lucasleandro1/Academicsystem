class Direction::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_teacher, only: [ :show, :edit, :update, :destroy ]

  def index
    @school = current_user.school
    @teachers = User.where(school_id: @school.id, user_type: "teacher")

    # Filtros
    if params[:search].present?
      @teachers = @teachers.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:subject_id].present?
      @teachers = @teachers.joins(:teacher_subjects).where(subjects: { id: params[:subject_id] }).distinct
    end

    @teachers = @teachers.order(:first_name, :last_name)
  end

  def show
    @subjects = Subject.where(user_id: @teacher.id)
    @classrooms = Classroom.joins(:subjects).where(subjects: { user_id: @teacher.id }).distinct
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params.merge(user_type: :teacher, school_id: current_user.school.id))

    if @user.save
      redirect_to direction_teachers_path, notice: "Professor criado com sucesso."
    else
      render :new
    end
  end

  def update
    if @teacher.update(user_params)
      redirect_to direction_teacher_path(@teacher), notice: "Professor atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @teacher.destroy
    redirect_to direction_teachers_path, notice: "Professor removido com sucesso."
  end

  private

  def set_teacher
    @user = User.where(school_id: current_user.school.id, user_type: "teacher", id: params[:id]).first

    unless @user
      redirect_to direction_teachers_path, alert: "Professor não encontrado."
    end

    @teacher = @user
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name,
      :phone
    )
  end
end
