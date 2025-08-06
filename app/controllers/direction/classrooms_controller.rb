class Direction::ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_classroom, only: [ :show, :edit, :update, :destroy ]

  def index
    @classrooms = current_user.school.classrooms.includes(:students, :subjects)
  end

  def show
    @enrollments = @classroom.enrollments.includes(:student)
    @subjects = @classroom.subjects.includes(:teacher)
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

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_classroom
    @classroom = current_user.school.classrooms.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :academic_year, :shift, :level)
  end
end
