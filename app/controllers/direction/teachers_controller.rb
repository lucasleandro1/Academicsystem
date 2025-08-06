class Direction::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_teacher, only: [ :show, :edit, :update, :destroy ]

  def index
    @school = current_user.school
    @teachers = User.where(school_id: @school.id, user_type: "teacher")

    # Filtros
    if params[:search].present?
      @teachers = @teachers.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR registration_number ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:active].present?
      @teachers = @teachers.where(active: params[:active] == "true")
    end

    if params[:specialization].present?
      @teachers = @teachers.where("specialization ILIKE ?", "%#{params[:specialization]}%")
    end

    @teachers = @teachers.order(:first_name, :last_name)
  end

  def show
    @subjects = Subject.where(teacher: @teacher)
    @classrooms = Classroom.joins(:subjects).where(subjects: { teacher: @teacher }).distinct
    @activities = Activity.joins(:subject).where(subjects: { teacher: @teacher }).order(created_at: :desc).limit(10)
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
    if @user.update(user_params)
      redirect_to direction_teacher_path(@user), notice: "Professor atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to direction_teachers_path, notice: "Professor removido com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

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
      :phone, :birth_date, :cpf, :registration_number, :position,
      :specialization, :active
    )
  end
end
