class Direction::SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_subject, only: [ :show, :edit, :update, :destroy ]

  def index
    @subjects = current_user.school.subjects.includes(:classroom, :teacher)
  end

  def show
    @activities = @subject.activities.recent
    @grades = @subject.grades.includes(:student)
    @class_schedules = @subject.class_schedules
  end

  def new
    @subject = current_user.school.subjects.build
    @classrooms = current_user.school.classrooms
    @teachers = current_user.school.teachers.active
  end

  def edit
    @classrooms = current_user.school.classrooms
    @teachers = current_user.school.teachers.active
  end

  def create
    @subject = current_user.school.subjects.build(subject_params)

    if @subject.save
      redirect_to direction_subject_path(@subject), notice: "Disciplina criada com sucesso."
    else
      @classrooms = current_user.school.classrooms
      @teachers = current_user.school.teachers.active
      render :new
    end
  end

  def update
    if @subject.update(subject_params)
      redirect_to direction_subject_path(@subject), notice: "Disciplina atualizada com sucesso."
    else
      @classrooms = current_user.school.classrooms
      @teachers = current_user.school.teachers.active
      render :edit
    end
  end

  def destroy
    @subject.destroy
    redirect_to direction_subjects_path, notice: "Disciplina removida com sucesso."
  end

  private

  def set_subject
    @subject = current_user.school.subjects.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :classroom_id, :user_id, :workload)
  end
end
