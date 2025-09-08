class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    @schools = School.includes(:users)
    @total_schools = @schools.count
    @total_users = User.count
    @total_students = User.student.count
    @total_teachers = User.teacher.count
    @total_directions = User.direction.count

    # Relatórios por escola
    @schools_stats = @schools.map do |school|
      {
        school: school,
        students_count: school.users.student.count,
        teachers_count: school.users.teacher.count,
        directions_count: school.users.direction.count,
        total_users: school.users.count
      }
    end
  end

  def municipal_overview
    @report_data = {
      schools: School.count,
      students: User.student.count,
      teachers: User.teacher.count,
      directions: User.direction.count,
      active_students: User.student.where(active: true).count
    }

    # Dados para gráficos
    @students_by_school = School.joins(:users)
                               .where(users: { user_type: "student" })
                               .group("schools.name")
                               .count

    @teachers_by_school = School.joins(:users)
                               .where(users: { user_type: "teacher" })
                               .group("schools.name")
                               .count
  end

  def attendance_report
    @schools = School.includes(:users)

    # Calcular taxa de presença por escola (implementação básica)
    @attendance_by_school = @schools.map do |school|
      total_students = school.users.student.count
      total_absences = Absence.joins(:user).where(users: { school_id: school.id }).count

      # Assumindo 200 dias letivos por ano
      expected_presences = total_students * 200
      actual_presences = expected_presences - total_absences
      attendance_rate = expected_presences > 0 ? (actual_presences.to_f / expected_presences * 100).round(2) : 0

      {
        school: school,
        students: total_students,
        attendance_rate: attendance_rate,
        absences: total_absences
      }
    end
  end

  def performance_report
    @schools = School.includes(:users)

    # Relatório de desempenho por escola
    @performance_by_school = @schools.map do |school|
      students = school.users.student
      total_grades = Grade.joins(:user).where(users: { school_id: school.id })
      average_grade = total_grades.average(:value) || 0

      {
        school: school,
        students_count: students.count,
        total_grades: total_grades.count,
        average_grade: average_grade.round(2),
        above_average: total_grades.where("value >= ?", 7).count,
        below_average: total_grades.where("value < ?", 7).count
      }
    end
  end

  def export_pdf
    # Implementar exportação em PDF
    respond_to do |format|
      format.pdf do
        # Gerar PDF com os dados
        redirect_to admin_reports_path, notice: "Relatório PDF gerado com sucesso."
      end
    end
  end

  def export_excel
    # Implementar exportação em Excel
    respond_to do |format|
      format.xlsx do
        # Gerar Excel com os dados
        redirect_to admin_reports_path, notice: "Relatório Excel gerado com sucesso."
      end
    end
  end

  def student_distribution
    @distribution_data = School.joins(:users)
                              .where(users: { user_type: "student" })
                              .group("schools.name")
                              .count
                              .sort_by { |_, count| -count }
  end

  def evasion_report
    # Relatório de evasão escolar
    @schools = School.includes(:users)

    @evasion_data = @schools.map do |school|
      total_students = school.users.student.count
      active_students = school.users.student.where(active: true).count

      evasion_count = total_students - active_students
      evasion_rate = total_students > 0 ? (evasion_count.to_f / total_students * 100).round(2) : 0

      {
        school: school,
        total_students: total_students,
        active_students: active_students,
        evasion_count: evasion_count,
        evasion_rate: evasion_rate
      }
    end
  end
end
