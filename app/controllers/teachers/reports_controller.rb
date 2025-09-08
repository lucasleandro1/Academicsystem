class Teachers::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @subjects = current_user.subjects.includes(:classroom)
    @classrooms = available_classrooms
  end

  def student_performance
    @subject = current_user.subjects.find(params[:subject_id]) if params[:subject_id]
    @classroom = Classroom.find(params[:classroom_id]) if params[:classroom_id]

    if @subject
      @students = @subject.students.includes(:grades, :absences)
      @grades = Grade.where(subject: @subject).includes(:student)
      @student_performance = calculate_student_performance(@students, @subject)
    elsif @classroom
      @students = @classroom.students
      @subjects = current_user.subjects.where(classroom: @classroom)
      @classroom_performance = calculate_classroom_performance(@students, @subjects)
    end

    respond_to do |format|
      format.html
      format.pdf { render_pdf("relatorio_desempenho_alunos") }
    end
  end

  def classroom_attendance
    @classroom = Classroom.find(params[:classroom_id]) if params[:classroom_id]
    @subject = current_user.subjects.find(params[:subject_id]) if params[:subject_id]

    @start_date = params[:start_date]&.to_date || 1.month.ago
    @end_date = params[:end_date]&.to_date || Date.current

    if @subject
      @attendance_data = calculate_subject_attendance(@subject, @start_date, @end_date)
    elsif @classroom
      @subjects = current_user.subjects.where(classroom: @classroom)
      @attendance_data = calculate_classroom_attendance(@classroom, @subjects, @start_date, @end_date)
    end

    respond_to do |format|
      format.html
      format.pdf { render_pdf("relatorio_frequencia") }
    end
  end

  def grade_summary
    @subject = current_user.subjects.find(params[:subject_id]) if params[:subject_id]
    @classroom = Classroom.find(params[:classroom_id]) if params[:classroom_id]

    if @subject
      @grade_summary = calculate_subject_grades(@subject)
    elsif @classroom
      @subjects = current_user.subjects.where(classroom: @classroom)
      @grade_summary = calculate_classroom_grades(@classroom, @subjects)
    end

    respond_to do |format|
      format.html
      format.pdf { render_pdf("relatorio_notas") }
    end
  end

  def export_pdf
    # Implementar exportação em PDF
    redirect_to teachers_reports_path, notice: "Funcionalidade em desenvolvimento."
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def available_classrooms
    classroom_ids = current_user.subjects.pluck(:classroom_id).uniq
    Classroom.where(id: classroom_ids)
  end

  def calculate_student_performance(students, subject)
    students.map do |student|
      grades = student.grades.where(subject: subject)
      absences = student.absences.where(subject: subject)

      {
        student: student,
        average_grade: grades.average(:value) || 0,
        total_grades: grades.count,
        total_absences: absences.count,
        attendance_rate: calculate_attendance_rate(student, subject)
      }
    end
  end

  def calculate_classroom_performance(students, subjects)
    subjects.map do |subject|
      subject_students = students.where(classroom: subject.classroom)

      grades = Grade.where(subject: subject, student: subject_students)

      {
        subject: subject,
        average_grade: grades.average(:value) || 0,
        students_count: subject_students.count,
        grades_count: grades.count
      }
    end
  end

  def calculate_subject_attendance(subject, start_date, end_date)
    students = subject.students
    absences = Absence.where(
      subject: subject,
      student: students,
      date: start_date..end_date
    )

    students.map do |student|
      student_absences = absences.where(student: student).count
      total_classes = calculate_total_classes(subject, start_date, end_date)
      attendance_rate = total_classes > 0 ? ((total_classes - student_absences) * 100.0 / total_classes) : 100

      {
        student: student,
        absences: student_absences,
        total_classes: total_classes,
        attendance_rate: attendance_rate.round(1)
      }
    end
  end

  def calculate_classroom_attendance(classroom, subjects, start_date, end_date)
    classroom.students.map do |student|
      total_absences = 0
      total_classes = 0

      subjects.each do |subject|
        absences = Absence.where(
          subject: subject,
          student: student,
          date: start_date..end_date
        ).count

        classes = calculate_total_classes(subject, start_date, end_date)

        total_absences += absences
        total_classes += classes
      end

      attendance_rate = total_classes > 0 ? ((total_classes - total_absences) * 100.0 / total_classes) : 100

      {
        student: student,
        absences: total_absences,
        total_classes: total_classes,
        attendance_rate: attendance_rate.round(1)
      }
    end
  end

  def calculate_subject_grades(subject)
    grades = Grade.where(subject: subject).includes(:student)

    {
      subject: subject,
      total_grades: grades.count,
      average_grade: grades.average(:value) || 0,
      highest_grade: grades.maximum(:value) || 0,
      lowest_grade: grades.minimum(:value) || 0,
      students_with_grades: grades.distinct.count(:student_id)
    }
  end

  def calculate_classroom_grades(classroom, subjects)
    subjects.map do |subject|
      calculate_subject_grades(subject)
    end
  end

  def calculate_attendance_rate(student, subject)
    # Lógica simplificada - pode ser melhorada
    total_classes = 40 # Aproximação baseada no semestre
    absences = student.absences.where(subject: subject).count
    ((total_classes - absences) * 100.0 / total_classes).round(1)
  end

  def calculate_total_classes(subject, start_date, end_date)
    # Lógica simplificada - contar aulas baseado na grade horária
    # Pode ser melhorada com um sistema mais preciso de controle de aulas
    weeks = ((end_date - start_date) / 7).ceil
    classes_per_week = subject.class_schedules.count
    weeks * classes_per_week
  end

  def render_pdf(template_name)
    # Implementação de geração de PDF seria aqui
    # Por enquanto, redireciona para HTML
    redirect_to teachers_reports_path, notice: "Visualização em PDF em desenvolvimento."
  end
end
