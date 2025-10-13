class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @student = current_user
    @classroom = @student.classroom
    @subjects = @classroom&.subjects || []
    @total_subjects = @subjects.count

    # Grades and performance
    @recent_grades = @student.grades.includes(:subject).order(created_at: :desc).limit(5)
    @overall_average = calculate_overall_average

    # Messages
    @recent_messages = @student.received_messages.unread.order(created_at: :desc).limit(5)
    @unread_messages = @student.received_messages.unread.count

    # Attendance
    @total_absences = @student.absences.count
    @attendance_rate = calculate_attendance_rate

    # Schedule
    @today_schedule = get_today_schedule

    # Events
    @upcoming_events = Event.where(school: @student.school)
                           .where("start_date >= ?", Date.current)
                           .order(:start_date)
                           .limit(3)
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def calculate_overall_average
    grades = @student.grades.where.not(value: nil)
    return 0 if grades.empty?

    (grades.sum(:value) / grades.count.to_f).round(2)
  end

  def calculate_attendance_rate
    return 100 if @classroom.nil?

    # Calcular com base no período letivo (assumindo que já passou algumas semanas)
    weeks_passed = [ (Date.current - Date.current.beginning_of_year).to_i / 7, 1 ].max
    total_possible_classes = @classroom.class_schedules.count * weeks_passed

    return 100 if total_possible_classes == 0

    present_classes = total_possible_classes - @total_absences
    attendance_rate = ((present_classes.to_f / total_possible_classes) * 100).round(0)

    # Garantir que não seja negativo
    [ attendance_rate, 0 ].max
  end

  def get_today_schedule
    return [] if @classroom.nil?

    # Converter dia atual para número (0=Domingo, 1=Segunda, ..., 6=Sábado)
    today_weekday = Date.current.wday

    @classroom.class_schedules
              .joins(:subject)
              .includes(subject: :teacher)
              .where(weekday: today_weekday)
              .order(:start_time)
  end
end
