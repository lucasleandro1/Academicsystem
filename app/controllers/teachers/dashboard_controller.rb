class Teachers::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @teacher = current_user
    @subjects = @teacher.teacher_subjects.includes(:classroom, :school, class_schedules: :classroom)
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
  end

  private


  def total_students_count
    classroom_ids = @teacher.teacher_classrooms.pluck(:id)
    User.where(classroom_id: classroom_ids, user_type: "student").count
  end

  def classes_today
    today_weekday = Date.current.wday
    @teacher.class_schedules
            .where(weekday: today_weekday)
            .includes(:classroom, :subject)
  end

  def calculate_average_grade
    # Calculate average grade across all teacher's subjects
    grades = Grade.joins(:subject).where(subjects: { user_id: @teacher.id })
    return nil if grades.empty?
    grades.average(:value)&.round(2)
  end

  def calculate_attendance_rate
    # Calculate attendance rate across all teacher's students
    classroom_ids = @teacher.teacher_classrooms.pluck(:id)
    total_students = User.where(classroom_id: classroom_ids, user_type: "student").count
    return nil if total_students.zero?

    total_absences = Absence.joins(:subject).where(subjects: { user_id: @teacher.id }).count
    total_possible_classes = total_students * @teacher.teacher_subjects.count * 30 # Assume 30 classes per subject per month
    return nil if total_possible_classes.zero?

    ((total_possible_classes - total_absences).to_f / total_possible_classes * 100).round(2)
  end
end
