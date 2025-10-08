class Teachers::GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_grade, only: [ :show, :edit, :update, :destroy ]

  def index
    @subjects = current_user.teacher_subjects.includes(:classroom)
    @selected_subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : @subjects.first
    @grades = @selected_subject&.grades&.includes(:student) || Grade.none
  end

  def show
  end

  def new
    @grade = Grade.new
    @subjects = current_user.teacher_subjects
    @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
    @students = @subject&.students || []
  end

  def edit
    @subjects = current_user.teacher_subjects
    @students = @grade.subject.students
  end

  def create
    @grade = Grade.new(grade_params)

    if @grade.save
      redirect_to teachers_grades_path(subject_id: @grade.subject_id), notice: "Nota registrada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @subject = Subject.find(grade_params[:subject_id]) if grade_params[:subject_id]
      @students = @subject&.students || []
      render :new
    end
  end

  def update
    if @grade.update(grade_params)
      redirect_to teachers_grades_path(subject_id: @grade.subject_id), notice: "Nota atualizada com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = @grade.subject.students
      render :edit
    end
  end

  def destroy
    subject_id = @grade.subject_id
    @grade.destroy
    redirect_to teachers_grades_path(subject_id: subject_id), notice: "Nota removida com sucesso."
  end

  private

  def set_grade
    @grade = Grade.joins(:subject).where(subjects: { user_id: current_user.id }).find(params[:id])
  end

  def grade_params
    params.require(:grade).permit(:subject_id, :user_id, :bimester, :value, :grade_type)
  end
end
