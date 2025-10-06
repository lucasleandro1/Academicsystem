class Direction::ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_classroom, only: [ :show, :edit, :update, :destroy, :add_student, :remove_student ]

  def index
    @classrooms = current_user.school.classrooms.includes(:students, :subjects)

    # Filtros
    if params[:search].present?
      @classrooms = @classrooms.where("name ILIKE ?", "%#{params[:search]}%")
    end

    if params[:level].present?
      @classrooms = @classrooms.where(level: params[:level])
    end

    if params[:shift].present?
      @classrooms = @classrooms.where(shift: params[:shift])
    end

    @classrooms = @classrooms.order(:name)
  end

  def show
    @students = @classroom.students
    @subjects = @classroom.subjects.includes(:user)
    @class_schedules = @classroom.class_schedules.includes(:subject).by_time
  end

  def new
    @classroom = current_user.school.classrooms.build
  end

  def edit
  end

  def create
    @classroom = current_user.school.classrooms.build(classroom_params)

    if @classroom.save
      redirect_to direction_classroom_path(@classroom), notice: "Turma criada com sucesso."
    else
      render :new
    end
  end

  def update
    if @classroom.update(classroom_params)
      redirect_to direction_classroom_path(@classroom), notice: "Turma atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @classroom.destroy
    redirect_to direction_classrooms_path, notice: "Turma removida com sucesso."
  end

  def add_student
    @student = User.find(params[:user_id])
    if @student.update(classroom: @classroom)
      redirect_to direction_classroom_path(@classroom), notice: "Aluno adicionado à turma com sucesso."
    else
      redirect_to direction_classroom_path(@classroom), alert: "Erro ao adicionar aluno à turma."
    end
  end

  def remove_student
    @student = User.find(params[:student_id])
    if @student.update(classroom: nil)
      redirect_to direction_classroom_path(@classroom), notice: "Aluno removido da turma com sucesso."
    else
      redirect_to direction_classroom_path(@classroom), alert: "Erro ao remover aluno da turma."
    end
  end



  private

  def set_classroom
    @classroom = current_user.school.classrooms.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :academic_year, :shift, :level)
  end
end
