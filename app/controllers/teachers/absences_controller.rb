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

  def show
  end

  def new
    @absence = Absence.new
    @subjects = current_user.teacher_subjects
    @subject = params[:subject_id] ? current_user.teacher_subjects.find(params[:subject_id]) : nil
    @students = @subject&.students || []
  end

  def edit
    @subjects = current_user.subjects
    @students = @absence.subject.students
  end

  def create
    @absence = Absence.new(absence_params)

    if @absence.save
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta registrada com sucesso."
    else
      @subjects = current_user.subjects
      @subject = Subject.find(absence_params[:subject_id]) if absence_params[:subject_id]
      @students = @subject&.students || []
      render :new
    end
  end

  def update
    if @absence.update(absence_params)
      redirect_to teachers_absences_path(subject_id: @absence.subject_id), notice: "Falta atualizada com sucesso."
    else
      @subjects = current_user.subjects
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

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_absence
    @absence = Absence.joins(:subject).where(subjects: { user_id: current_user.id }).find(params[:id])
  end

  def absence_params
    params.require(:absence).permit(:subject_id, :user_id, :date, :justified)
  end
end
