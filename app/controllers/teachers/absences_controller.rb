class Teachers::AbsencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_absence, only: [ :show, :edit, :update, :destroy ]

  def index
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @selected_subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : @subjects.first
    @absences = @selected_subject&.absences&.includes(:student) || Absence.none
    @students = @selected_subject&.students || []
  end

  def attendance
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
    @classrooms = @subject&.available_classrooms || []
    @selected_classroom = params[:classroom_id] ? Classroom.find(params[:classroom_id]) : nil
    @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []
    @date = params[:date] ? Date.parse(params[:date]) : Date.current

    # Buscar faltas já registradas para esta data, disciplina e turma
    if @subject && @selected_classroom && @date
      existing_absences = @subject.absences.where(
        date: @date,
        user_id: @students.pluck(:id)
      )
      @absent_student_ids = existing_absences.pluck(:user_id)
    else
      @absent_student_ids = []
    end
  end

  def bulk_create
    @subject = current_user.teacher_subjects.find(params[:subject_id])
    @selected_classroom = Classroom.find(params[:classroom_id])
    @students = @subject.students_from_classroom(@selected_classroom.id)
    @date = Date.parse(params[:date])

    # Obter lista de alunos faltosos
    absent_student_ids = params[:absent_students] || []

    # Limpar faltas existentes para esta data/disciplina/turma
    existing_absences = @subject.absences.where(
      date: @date,
      user_id: @students.pluck(:id)
    )
    existing_absences.destroy_all

    # Criar novas faltas
    success_count = 0
    absent_student_ids.each do |student_id|
      if @students.pluck(:id).include?(student_id.to_i)
        absence = @subject.absences.build(
          user_id: student_id,
          date: @date,
          justified: false
        )
        if absence.save
          success_count += 1
        end
      end
    end

    redirect_to attendance_teachers_absences_path(
      subject_id: @subject.id,
      classroom_id: @selected_classroom.id,
      date: @date
    ), notice: "Chamada registrada! #{success_count} falta(s) registrada(s)."
  end

  def show
  end

  def new
    @absence = Absence.new
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
    @classrooms = @subject&.available_classrooms || []
    @selected_classroom = params[:classroom_id] ? Classroom.find(params[:classroom_id]) : nil
    @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []

    # Preservar dados do form se houver erro de validação
    if params[:absence]
      @absence.assign_attributes(absence_params)
      # Recuperar classroom_id dos parâmetros se disponível
      @selected_classroom = params[:absence][:classroom_id].present? ? Classroom.find(params[:absence][:classroom_id]) : @selected_classroom
      @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : @students
    end
  end

  def edit
    @subjects = current_user.teacher_subjects
    @students = @absence.subject.students
  end

  def create
    @absence = Absence.new(absence_params)

    if @absence.save
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta registrada com sucesso."
    else
      @subjects = current_user.teacher_subjects.includes(:classroom)
      @subject = Subject.find(absence_params[:subject_id]) if absence_params[:subject_id]
      @classrooms = @subject&.available_classrooms || []
      # Obter classroom_id dos parâmetros da requisição, não do model absence
      @selected_classroom = params[:absence][:classroom_id].present? ? Classroom.find(params[:absence][:classroom_id]) : nil
      @students = @selected_classroom ? @subject&.students_from_classroom(@selected_classroom.id) || [] : []
      render :new
    end
  end

  def update
    if @absence.update(absence_params)
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta atualizada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = @absence.subject.students
      render :edit
    end
  end

  def destroy
    subject_id = @absence.subject_id
    @absence.destroy
    redirect_to teachers_absences_path(subject_id: subject_id), notice: "Falta removida com sucesso."
  end

  private

  def set_absence
    @absence = Absence.joins(:subject).where(subjects: { user_id: current_user.id }).find(params[:id])
  end

  def absence_params
    params.require(:absence).permit(:subject_id, :user_id, :date, :justified)
  end
end
