class Direction::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school

    # Relatórios de alunos
    @students_report = {
      total: User.joins(student_enrollments: :classroom).where(classrooms: { school_id: @school.id }, user_type: "student").distinct.count,
      active: User.joins(student_enrollments: :classroom).where(classrooms: { school_id: @school.id }, enrollments: { status: "active" }, user_type: "student").distinct.count,
      pending: Enrollment.joins(:classroom).where(classrooms: { school_id: @school.id }, status: "pending").count,
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
  end

  def attendance_report
    @school = current_user.school
    @classrooms = @school.classrooms.includes(:students)

    # Filtros
    @selected_classroom = params[:classroom_id].present? ? @school.classrooms.find(params[:classroom_id]) : nil
    @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 1.month.ago.to_date
    @date_to = params[:date_to].present? ? Date.parse(params[:date_to]) : Date.current

    # Dados de frequência
    if @selected_classroom
      @attendance_data = attendance_data_for_classroom(@selected_classroom, @date_from, @date_to)
    else
      @attendance_data = attendance_data_for_school(@date_from, @date_to)
    end
  end

  def grades_report
    @school = current_user.school
    @classrooms = @school.classrooms.includes(:students, :subjects)

    # Filtros
    @selected_classroom = params[:classroom_id].present? ? @school.classrooms.find(params[:classroom_id]) : nil
    @selected_subject = params[:subject_id].present? ? Subject.find(params[:subject_id]) : nil

    # Dados de notas
    if @selected_classroom
      @grades_data = grades_data_for_classroom(@selected_classroom, @selected_subject)
    else
      @grades_data = grades_data_for_school(@selected_subject)
    end
  end

  def student_bulletin
    @school = current_user.school
    @student = params[:student_id].present? ? User.find(params[:student_id]) : nil
    @students = @school.students.order(:full_name)

    if @student
      @bulletin_data = generate_student_bulletin(@student)
    end
  end

  def performance_stats
    @school = current_user.school
    @performance_data = {
      grade_distribution: calculate_grade_distribution,
      attendance_trends: calculate_attendance_trends,
      subject_performance: calculate_subject_performance,
      classroom_comparison: calculate_classroom_comparison
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
        .joins("LEFT JOIN subjects ON subjects.user_id = users.id")
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

  def attendance_data_for_classroom(classroom, date_from, date_to)
    students = classroom.students
    attendance_data = {}

    students.each do |student|
      absences = student.absences.where(date: date_from..date_to).count
      total_days = (date_to - date_from).to_i + 1
      attendance_rate = ((total_days - absences).to_f / total_days * 100).round(1)

      attendance_data[student.full_name] = {
        absences: absences,
        attendance_rate: attendance_rate,
        total_days: total_days
      }
    end

    attendance_data
  end

  def attendance_data_for_school(date_from, date_to)
    current_user.school.classrooms.includes(:students).map do |classroom|
      students_data = attendance_data_for_classroom(classroom, date_from, date_to)
      average_attendance = students_data.values.map { |data| data[:attendance_rate] }.sum / students_data.size if students_data.any?

      {
        classroom_name: classroom.name,
        students_count: students_data.size,
        average_attendance: average_attendance&.round(1) || 0,
        students_data: students_data
      }
    end
  end

  def grades_data_for_classroom(classroom, subject = nil)
    query = Grade.joins(student: :enrollments)
                 .where(enrollments: { classroom_id: classroom.id })

    query = query.joins(:subject).where(subjects: { id: subject.id }) if subject

    grades = query.includes(:student, :subject)

    grades.group_by(&:student).map do |student, student_grades|
      {
        student_name: student.full_name,
        grades: student_grades.map { |g| { subject: g.subject.name, grade: g.value } },
        average: student_grades.sum(&:value) / student_grades.size.to_f
      }
    end
  end

  def grades_data_for_school(subject = nil)
    current_user.school.classrooms.includes(:students).map do |classroom|
      classroom_grades = grades_data_for_classroom(classroom, subject)
      average_grade = classroom_grades.map { |data| data[:average] }.sum / classroom_grades.size if classroom_grades.any?

      {
        classroom_name: classroom.name,
        students_count: classroom_grades.size,
        average_grade: average_grade&.round(1) || 0,
        students_data: classroom_grades
      }
    end
  end

  def generate_student_bulletin(student)
    enrollments = student.enrollments.includes(:classroom, :school)
    current_enrollment = enrollments.find { |e| e.school_id == current_user.school.id }

    return nil unless current_enrollment

    classroom = current_enrollment.classroom
    subjects = classroom.subjects.includes(:grades, :absences)

    bulletin_data = {
      student: student,
      classroom: classroom,
      subjects_data: []
    }

    subjects.each do |subject|
      student_grades = subject.grades.where(student: student)
      student_absences = subject.absences.where(student: student).count

      average_grade = student_grades.any? ? student_grades.average(:value).round(1) : 0

      bulletin_data[:subjects_data] << {
        subject_name: subject.name,
        grades: student_grades.pluck(:value),
        average: average_grade,
        absences: student_absences,
        teacher: subject.user&.full_name
      }
    end

    bulletin_data
  end

  def calculate_grade_distribution
    Grade.joins(student: :enrollments)
         .where(enrollments: { school_id: current_user.school.id })
         .group("CASE
                   WHEN value >= 9 THEN '9-10'
                   WHEN value >= 7 THEN '7-8.9'
                   WHEN value >= 5 THEN '5-6.9'
                   ELSE 'Abaixo de 5'
                 END")
         .count
  end

  def calculate_attendance_trends
    3.downto(0).map do |months_ago|
      start_date = months_ago.months.ago.beginning_of_month
      end_date = months_ago.months.ago.end_of_month
      month_name = start_date.strftime("%B/%Y")

      attendance_rate = calculate_month_attendance_rate(start_date, end_date)

      { month: month_name, attendance_rate: attendance_rate }
    end
  end

  def calculate_month_attendance_rate(start_date, end_date)
    total_enrollments = Enrollment.where(school_id: current_user.school.id, status: "active").count
    return 0 if total_enrollments.zero?

    total_absences = Absence.joins(student: :enrollments)
                           .where(enrollments: { school_id: current_user.school.id })
                           .where(date: start_date..end_date)
                           .count

    days_in_period = (end_date.to_date - start_date.to_date).to_i + 1
    expected_presences = total_enrollments * days_in_period

    return 95.0 if total_absences.zero?
    [ 100.0 - (total_absences.to_f / expected_presences * 100), 0 ].max.round(1)
  end

  def calculate_subject_performance
    Subject.joins(classroom: :school)
           .where(schools: { id: current_user.school.id })
           .joins("LEFT JOIN grades ON subjects.id = grades.subject_id")
           .group("subjects.name")
           .average("grades.value")
           .transform_values { |avg| avg&.round(1) || 0 }
  end

  def calculate_classroom_comparison
    current_user.school.classrooms.includes(:grades).map do |classroom|
      grades = classroom.grades
      average_grade = grades.any? ? grades.average(:value).round(1) : 0
      students_count = classroom.students.count

      {
        name: classroom.name,
        average_grade: average_grade,
        students_count: students_count
      }
    end
  end
end
