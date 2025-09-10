class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @student = current_user
    @classroom = @student.classroom
    @subjects = @classroom&.subjects || []
    @recent_grades = @student.grades.includes(:subject).order(created_at: :desc).limit(5)
    @recent_messages = @student.received_messages.unread.order(created_at: :desc).limit(5)
    @upcoming_activities = upcoming_activities
    @total_absences = @student.absences.count
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def upcoming_activities
    return Activity.none unless @student.classroom

    subject_ids = @student.classroom.subjects.pluck(:id)
    Activity.where(subject_id: subject_ids)
            .where("due_date > ?", Date.current)
            .order(:due_date)
            .limit(5)
  end
end
