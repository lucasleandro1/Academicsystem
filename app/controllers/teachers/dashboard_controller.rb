class Teachers::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @teacher = current_user
    @subjects = @teacher.teacher_subjects.includes(:classroom, :school)
    @recent_activities = @teacher.activities.recent.limit(5)
    @pending_submissions = pending_submissions
    @recent_messages = @teacher.received_messages.unread.recent.limit(5)
    @total_students = total_students_count
    @classes_today = classes_today
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def pending_submissions
    activity_ids = @teacher.activities.pluck(:id)
    Submission.joins(:activity)
              .where(activity_id: activity_ids, teacher_grade: nil)
              .includes(:student, :activity)
              .limit(10)
  end

  def total_students_count
    classroom_ids = @teacher.teacher_subjects.pluck(:classroom_id).uniq
    Enrollment.where(classroom_id: classroom_ids, status: "active").count
  end

  def classes_today
    today_weekday = Date.current.wday
    @teacher.teacher_subjects
            .joins(:class_schedules)
            .where(class_schedules: { weekday: today_weekday })
            .includes(:classroom, :class_schedules)
  end
end
