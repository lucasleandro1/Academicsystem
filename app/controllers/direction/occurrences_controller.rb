class Direction::OccurrencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_occurrence, only: [ :show, :edit, :update, :destroy ]

  def index
    @occurrences = current_user.school.occurrences
                               .includes(:student, :author)
                               .recent
    @students = current_user.school.students.active
  end

  def show
  end

  def new
    @occurrence = current_user.school.occurrences.build
    @students = current_user.school.students.active
  end

  def edit
    @students = current_user.school.students.active
  end

  def create
    @occurrence = current_user.school.occurrences.build(occurrence_params)
    @occurrence.author = current_user

    if @occurrence.save
      redirect_to direction_occurrence_path(@occurrence), notice: "Ocorrência registrada com sucesso."
    else
      @students = current_user.school.students.active
      render :new
    end
  end

  def update
    if @occurrence.update(occurrence_params)
      redirect_to direction_occurrence_path(@occurrence), notice: "Ocorrência atualizada com sucesso."
    else
      @students = current_user.school.students.active
      render :edit
    end
  end

  def destroy
    @occurrence.destroy
    redirect_to direction_occurrences_path, notice: "Ocorrência removida com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_occurrence
    @occurrence = current_user.school.occurrences.find(params[:id])
  end

  def occurrence_params
    params.require(:occurrence).permit(:user_id, :description, :occurrence_type, :date)
  end
end
