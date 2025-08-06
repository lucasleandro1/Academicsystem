class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @student = current_user
    @enrollments = @student.enrollments.includes(:classroom)
    @recent_grades = @student.grades.includes(:subject).order(created_at: :desc).limit(5)
    @recent_messages = @student.received_messages.unread.order(created_at: :desc).limit(5)
    @upcoming_activities = upcoming_activities
    @total_absences = @student.absences.count
    @recent_occurrences = @student.student_occurrences.order(created_at: :desc).limit(3)
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def upcoming_activities
    classroom_ids = @student.enrollments.pluck(:classroom_id)
    subject_ids = Subject.where(classroom_id: classroom_ids).pluck(:id)
    Activity.where(subject_id: subject_ids)
            .where("due_date > ?", Date.current)
            .order(:due_date)
            .limit(5)
  end
end
