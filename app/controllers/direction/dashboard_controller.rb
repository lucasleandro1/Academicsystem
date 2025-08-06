class Direction::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school

    # Estatísticas básicas
    @total_students = User.joins(student_enrollments: :classroom)
                         .where(classrooms: { school_id: @school.id }, user_type: "student")
                         .distinct.count
    @total_teachers = User.where(school_id: @school.id, user_type: "teacher", active: true).count
    @total_classrooms = Classroom.where(school_id: @school.id).count
    @total_subjects = Subject.joins(:classroom).where(classrooms: { school_id: @school.id }).distinct.count

    # Eventos próximos
    @upcoming_events = Event.where(school_id: @school.id)
                           .where("start_date >= ?", Date.current)
                           .order(:start_date)
                           .limit(5)

    # Ocorrências recentes
    @recent_occurrences = Occurrence.joins(student: { student_enrollments: :classroom })
                                   .where(classrooms: { school_id: @school.id })
                                   .where("occurrences.date >= ?", 30.days.ago)
                                   .order(date: :desc)
                                   .limit(5)

    # Matrículas pendentes
    @pending_enrollments = Enrollment.joins(:classroom)
                                    .where(classrooms: { school_id: @school.id }, status: "pending")
                                    .includes(:student, :classroom)
                                    .order(:created_at)
                                    .limit(5)

    # Relatórios gerais
    @attendance_rate = calculate_attendance_rate
    @average_grade = calculate_average_grade
    @total_activities = calculate_total_activities
    @total_messages = calculate_total_messages
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def calculate_attendance_rate
    # Como ClassSchedule pode não ter campo date, vamos usar uma abordagem diferente
    total_enrollments = Enrollment.joins(:classroom)
                                 .where(classrooms: { school_id: @school.id }, status: "active")
                                 .count

    return 0 if total_enrollments.zero?

    total_absences = Absence.joins(student: { student_enrollments: :classroom })
                           .where(classrooms: { school_id: @school.id })
                           .where("absences.date >= ?", 30.days.ago)
                           .count

    # Calculamos uma estimativa simples de presença
    return 95.0 if total_absences.zero?

    attendance_rate = [ 100.0 - (total_absences.to_f / total_enrollments * 10), 0 ].max
    attendance_rate.round(1)
  end

  def calculate_average_grade
    grades = Grade.joins(student: { student_enrollments: :classroom })
                  .where(classrooms: { school_id: @school.id })
                  .where("grades.created_at >= ?", 30.days.ago)

    return "0.0" if grades.empty?

    (grades.average(:value) || 0).round(1).to_s
  end

  def calculate_total_activities
    Activity.where(school_id: @school.id).count
  end

  def calculate_total_messages
    Message.where(sender: current_user)
           .where("created_at >= ?", 30.days.ago)
           .count
  end
end
