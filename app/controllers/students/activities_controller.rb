class Students::ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  before_action :set_activity, only: [ :show ]

  def index
    return redirect_to students_dashboard_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    @subject_ids = current_user.classroom.subjects.pluck(:id)
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
    return redirect_to students_activities_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    subject_ids = current_user.classroom.subjects.pluck(:id)
    @activity = Activity.where(subject_id: subject_ids).find(params[:id])
  end
end
