class Students::ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  before_action :set_activity, only: [ :show ]

  def index
    @classroom_ids = current_user.enrollments.pluck(:classroom_id)
    @subject_ids = Subject.where(classroom_id: @classroom_ids).pluck(:id)
    @activities = Activity.where(subject_id: @subject_ids)
                         .includes(:subject, :submissions)
                         .order(:due_date)

    @submitted_activities = current_user.submissions.pluck(:activity_id)
  end

  def show
    @submission = current_user.submissions.find_by(activity: @activity)
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
    @activity = Activity.where(subject_id: subject_ids).find(params[:id])
  end
end
