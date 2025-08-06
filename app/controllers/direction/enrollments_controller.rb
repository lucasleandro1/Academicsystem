class Direction::EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_enrollment, only: [ :show, :approve, :reject, :destroy ]

  def index
    @pending_enrollments = current_user.school.enrollments
                                      .where(status: "pending")
                                      .includes(:student, :classroom)
    @active_enrollments = current_user.school.enrollments
                                     .where(status: "active")
                                     .includes(:student, :classroom)
  end

  def show
  end

  def new
    @enrollment = Enrollment.new
    @students = current_user.school.students.active
    @classrooms = current_user.school.classrooms
  end

  def create
    @enrollment = Enrollment.new(enrollment_params)
    @enrollment.status = "active"

    if @enrollment.save
      redirect_to direction_enrollments_path, notice: "Matrícula criada com sucesso."
    else
      @students = current_user.school.students.active
      @classrooms = current_user.school.classrooms
      render :new
    end
  end

  def approve
    if @enrollment.update(status: "active")
      redirect_to direction_enrollments_path, notice: "Matrícula aprovada com sucesso."
    else
      redirect_to direction_enrollments_path, alert: "Erro ao aprovar matrícula."
    end
  end

  def reject
    if @enrollment.update(status: "rejected")
      redirect_to direction_enrollments_path, notice: "Matrícula rejeitada."
    else
      redirect_to direction_enrollments_path, alert: "Erro ao rejeitar matrícula."
    end
  end

  def destroy
    @enrollment.destroy
    redirect_to direction_enrollments_path, notice: "Matrícula removida com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_enrollment
    @enrollment = current_user.school.enrollments.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:user_id, :classroom_id)
  end
end
