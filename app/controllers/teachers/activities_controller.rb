class Teachers::ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_activity, only: [ :show, :edit, :update, :destroy ]

  def index
    @activities = current_user.activities.includes(:subject, :submissions).recent
  end

  def show
    @submissions = @activity.submissions.includes(:student)
  end

  def new
    @activity = current_user.activities.build
    @subjects = current_user.teacher_subjects
  end

  def edit
    @subjects = current_user.teacher_subjects
  end

  def create
    @activity = current_user.activities.build(activity_params)
    @activity.school = current_user.school

    if @activity.save
      redirect_to teachers_activity_path(@activity), notice: "Atividade criada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      render :new
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to teachers_activity_path(@activity), notice: "Atividade atualizada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      render :edit
    end
  end

  def destroy
    @activity.destroy
    redirect_to teachers_activities_path, notice: "Atividade removida com sucesso."
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:subject_id, :title, :description, :due_date)
  end
end
