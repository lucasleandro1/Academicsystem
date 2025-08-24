class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    # Estatísticas gerais municipais
    @total_schools = School.count
    @total_students = User.students.active.count
    @total_teachers = User.teachers.active.count
    @total_directors = User.directions.active.count

    # Distribuição de alunos por escola
    @students_by_school = School.joins(:students)
                                .where(users: { user_type: "student", active: true })
                                .group("schools.name")
                                .count

    # Taxa de presença média geral
    @general_attendance_rate = calculate_general_attendance_rate

    # Matrículas ativas no município
    @active_enrollments = Enrollment.where(status: "active").count

    # Últimos comunicados enviados
    @recent_events = Event.order(created_at: :desc).limit(5)

    # Gráfico de distribuição de alunos por escola
    @school_distribution = @students_by_school.map { |school, count| [ school, count ] }

    # Relatório rápido de presença
    @attendance_summary = calculate_attendance_summary
  end

  private

  def calculate_general_attendance_rate
    total_enrollments = Enrollment.where(status: "active").count
    return 0 if total_enrollments.zero?

    total_absences = Absence.where("date >= ?", 30.days.ago).count
    return 95.0 if total_absences.zero?

    attendance_rate = [ 100.0 - (total_absences.to_f / total_enrollments * 10), 0 ].max
    attendance_rate.round(1)
  end

  def calculate_attendance_summary
    School.joins(:students)
          .where(users: { user_type: "student", active: true })
          .group("schools.name")
          .average("100 - (SELECT COUNT(*) FROM absences WHERE absences.user_id = users.id AND absences.date >= '#{30.days.ago.to_date}') * 10")
  end
end
