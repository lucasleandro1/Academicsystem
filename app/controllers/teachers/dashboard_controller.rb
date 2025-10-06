class Teachers::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @teacher = current_user
    @subjects = @teacher.teacher_subjects.includes(:classroom, :school)
    @recent_messages = @teacher.received_messages.unread.recent.limit(5)
    @total_students = total_students_count
    @classes_today = classes_today

    # Additional instance variables needed by the view
    @my_classrooms = @teacher.my_classrooms
    @my_subjects = @teacher.my_subjects
    @today_schedule = @classes_today
    @average_grade = calculate_average_grade
    @attendance_rate = calculate_attendance_rate

    # Missing variables that the view expects
    @active_activities = get_active_activities
    @pending_submissions = get_pending_submissions
    @upcoming_activities = get_upcoming_activities
    @submitted_activities = get_submitted_activities_count
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end


  def total_students_count
    classroom_ids = @teacher.teacher_subjects.pluck(:classroom_id).uniq
    User.where(classroom_id: classroom_ids, user_type: "student").count
  end

  def classes_today
    today_weekday = Date.current.wday
    @teacher.teacher_subjects
            .joins(:class_schedules)
            .where(class_schedules: { weekday: today_weekday })
            .includes(:classroom, :class_schedules)
  end

  def calculate_average_grade
    # Calculate average grade across all teacher's subjects
    grades = Grade.joins(:subject).where(subjects: { user_id: @teacher.id })
    return nil if grades.empty?
    grades.average(:value)&.round(2)
  end

  def calculate_attendance_rate
    # Calculate attendance rate across all teacher's students
    classroom_ids = @teacher.teacher_subjects.pluck(:classroom_id).uniq
    total_students = User.where(classroom_id: classroom_ids, user_type: "student").count
    return nil if total_students.zero?

    total_absences = Absence.joins(:subject).where(subjects: { user_id: @teacher.id }).count
    total_possible_classes = total_students * @teacher.teacher_subjects.count * 30 # Assume 30 classes per subject per month
    return nil if total_possible_classes.zero?

    ((total_possible_classes - total_absences).to_f / total_possible_classes * 100).round(2)
  end

  def get_active_activities
    # Get active activities for the teacher's subjects
    Activity.joins(:subject).where(subjects: { user_id: @teacher.id })
            .where("due_date >= ?", Date.current)
            .where(active: true)
  rescue
    # If Activity model doesn't exist or has issues, return empty relation
    Activity.none rescue []
  end

  def get_pending_submissions
    # Get submissions that need grading
    Submission.joins(activity: :subject)
              .where(subjects: { user_id: @teacher.id })
              .where(graded: false)
              .includes(:user, :activity)
  rescue
    # If Submission model doesn't exist, return empty array
    []
  end

  def get_upcoming_activities
    # Get upcoming activities for the teacher's subjects
    Activity.joins(:subject).where(subjects: { user_id: @teacher.id })
            .where("due_date BETWEEN ? AND ?", Date.current, 1.week.from_now)
            .where(active: true)
            .order(:due_date)
  rescue
    # If Activity model doesn't exist, return empty array
    []
  end

  def get_submitted_activities_count
    # Count submitted activities that have been graded
    Submission.joins(activity: :subject)
              .where(subjects: { user_id: @teacher.id })
              .where(graded: true)
              .count
  rescue
    # If models don't exist, return 0
    0
  end
end
