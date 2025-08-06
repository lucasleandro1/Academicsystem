class Students::SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  before_action :set_activity
  before_action :set_submission, only: [ :show, :edit, :update, :destroy ]

  def show
  end

  def new
    @submission = current_user.submissions.build(activity: @activity)
  end

  def edit
  end

  def create
    @submission = current_user.submissions.build(submission_params)
    @submission.activity = @activity
    @submission.school = current_user.school
    @submission.submission_date = Time.current

    if @submission.save
      redirect_to students_activity_path(@activity), notice: "Resposta enviada com sucesso."
    else
      render :new
    end
  end

  def update
    if @submission.update(submission_params)
      redirect_to students_activity_path(@activity), notice: "Resposta atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @submission.destroy
    redirect_to students_activity_path(@activity), notice: "Resposta removida com sucesso."
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_activity
    classroom_ids = current_user.enrollments.pluck(:classroom_id)
    subject_ids = Subject.where(classroom_id: classroom_ids).pluck(:id)
    @activity = Activity.where(subject_id: subject_ids).find(params[:activity_id])
  end

  def set_submission
    @submission = current_user.submissions.find_by!(activity: @activity)
  end

  def submission_params
    params.require(:submission).permit(:answer)
  end
end
