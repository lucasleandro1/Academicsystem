class Teachers::OccurrencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_occurrence, only: [ :show, :edit, :update, :destroy ]

  def index
    @occurrences = current_user.authored_occurrences
                              .includes(:student, :school)
                              .order(created_at: :desc)
  end

  def show
  end

  def new
    @occurrence = current_user.authored_occurrences.build
    @students = available_students
  end

  def edit
    @students = available_students
  end

  def create
    @occurrence = current_user.authored_occurrences.build(occurrence_params)
    @occurrence.school = current_user.school

    if @occurrence.save
      redirect_to teachers_occurrence_path(@occurrence), notice: "Ocorrência registrada com sucesso."
    else
      @students = available_students
      render :new
    end
  end

  def update
    if @occurrence.update(occurrence_params)
      redirect_to teachers_occurrence_path(@occurrence), notice: "Ocorrência atualizada com sucesso."
    else
      @students = available_students
      render :edit
    end
  end

  def destroy
    @occurrence.destroy
    redirect_to teachers_occurrences_path, notice: "Ocorrência removida com sucesso."
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_occurrence
    @occurrence = current_user.authored_occurrences.find(params[:id])
  end

  def occurrence_params
    params.require(:occurrence).permit(:user_id, :description, :occurrence_type, :date)
  end

  def available_students
    # Estudantes das turmas onde o professor leciona
    classroom_ids = current_user.subjects.pluck(:classroom_id)
    student_ids = Enrollment.where(classroom_id: classroom_ids, status: "active").pluck(:user_id)
    User.where(id: student_ids, user_type: "student")
  end
end
