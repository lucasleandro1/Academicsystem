class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @student = current_user
    @classroom = @student.classroom
    @subjects = @classroom&.subjects || []
    @recent_grades = @student.grades.includes(:subject).order(created_at: :desc).limit(5)
    @recent_messages = @student.received_messages.unread.order(created_at: :desc).limit(5)
    @total_absences = @student.absences.count
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
