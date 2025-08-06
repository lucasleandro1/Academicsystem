class Teachers::SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_activity
  before_action :set_submission, only: [ :show, :edit, :update ]

  def index
    @submissions = @activity.submissions.includes(:student)
  end

  def show
  end

  def edit
  end

  def update
    if @submission.update(submission_params)
      redirect_to teachers_activity_submission_path(@activity, @submission),
                  notice: "Correção salva com sucesso."
    else
      render :edit
    end
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_activity
    @activity = current_user.activities.find(params[:activity_id])
  end

  def set_submission
    @submission = @activity.submissions.find(params[:id])
  end

  def submission_params
    params.require(:submission).permit(:teacher_grade, :feedback)
  end
end
