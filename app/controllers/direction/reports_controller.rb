class Direction::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school

    # Relatórios de alunos
    @students_report = {
      total: User.joins(:enrollments).where(enrollments: { school_id: @school.id }, user_type: "student").distinct.count,
      active: User.joins(:enrollments).where(enrollments: { school_id: @school.id, status: "active" }, user_type: "student").distinct.count,
      pending: Enrollment.where(school_id: @school.id, status: "pending").count,
      by_classroom: classroom_enrollment_stats
    }

    # Relatórios de professores
    @teachers_report = {
      total: User.where(school_id: @school.id, user_type: "teacher").count,
      active: User.where(school_id: @school.id, user_type: "teacher", active: true).count,
      subjects_assigned: teacher_subject_stats
    }

    # Relatórios acadêmicos
    @academic_report = {
      attendance_rate: calculate_school_attendance_rate,
      average_grades: calculate_school_average_grades,
      total_activities: Activity.joins(subject: { classrooms: :school }).where(schools: { id: @school.id }).count,
      completed_activities: Activity.joins(subject: { classrooms: :school }).where(schools: { id: @school.id }, active: false).count
    }

    # Relatórios de ocorrências
    @occurrences_report = {
      total_this_month: Occurrence.joins(student: :enrollments).where(enrollments: { school_id: @school.id }).where("date >= ?", 1.month.ago).count,
      by_type: occurrence_type_stats,
      recent: Occurrence.joins(student: :enrollments).where(enrollments: { school_id: @school.id }).order(date: :desc).limit(10)
    }
  end

  def generate_pdf
    # Implementar geração de PDF dos relatórios
    respond_to do |format|
      format.pdf do
        render pdf: "relatorio_escola_#{@school.id}",
               template: "direction/reports/pdf_report",
               layout: "pdf"
      end
    end
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def classroom_enrollment_stats
    Classroom.where(school_id: current_user.school.id)
             .left_joins(:enrollments)
             .group("classrooms.name")
             .count("enrollments.id")
  end

  def teacher_subject_stats
    User.where(school_id: current_user.school.id, user_type: "teacher")
        .joins("LEFT JOIN subjects ON subjects.teacher_id = users.id")
        .group("users.first_name", "users.last_name")
        .count("subjects.id")
  end

  def calculate_school_attendance_rate
    total_schedules = ClassSchedule.joins(classroom: :school)
                                  .where(schools: { id: current_user.school.id })
                                  .where("date >= ?", 30.days.ago)
                                  .count

    return 0 if total_schedules.zero?

    total_absences = Absence.joins(student: :enrollments)
                           .where(enrollments: { school_id: current_user.school.id })
                           .where("date >= ?", 30.days.ago)
                           .count

    ((total_schedules - total_absences).to_f / total_schedules * 100).round(1)
  end

  def calculate_school_average_grades
    Grade.joins(student: :enrollments)
         .where(enrollments: { school_id: current_user.school.id })
         .where("grades.created_at >= ?", 30.days.ago)
         .average(:value)&.round(2) || 0
  end

  def occurrence_type_stats
    Occurrence.joins(student: :enrollments)
              .where(enrollments: { school_id: current_user.school.id })
              .where("date >= ?", 1.month.ago)
              .group(:occurrence_type)
              .count
  end
end
