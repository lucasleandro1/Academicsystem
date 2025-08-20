class Direction::EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_enrollment, only: [ :show, :approve, :reject, :destroy ]

  def index
    @enrollments = current_user.school.enrollments.includes(:student, :classroom)
    @pending_enrollments = @enrollments.where(status: "pending")
    @active_enrollments = @enrollments.where(status: "active")
  end

  def show
  end

  def new
    @enrollment = Enrollment.new
    @school = current_user.school
    @students = @school.students.active
    @classrooms = @school.classrooms
  end

  def create
    # Primeiro, criar o usuário estudante
    student_params = {
      name: params[:enrollment][:student_name],
      email: params[:enrollment][:student_email],
      cpf: params[:enrollment][:student_cpf],
      phone: params[:enrollment][:student_phone],
      address: params[:enrollment][:student_address],
      birth_date: params[:enrollment][:student_birth_date],
      user_type: "student",
      school: current_user.school,
      active: true,
      password: "password123", # Senha temporária
      password_confirmation: "password123"
    }

    @student = User.new(student_params)

    if @student.save
      # Criar a matrícula
      @enrollment = Enrollment.new(
        user: @student,
        classroom_id: params[:enrollment][:classroom_id],
        enrollment_date: params[:enrollment][:enrollment_date] || Date.current,
        status: params[:enrollment][:status] || "pending",
        notes: params[:enrollment][:notes]
      )

      if @enrollment.save
        redirect_to direction_enrollments_path, notice: "Matrícula criada com sucesso. Estudante: #{@student.name}"
      else
        @student.destroy # Remove o usuário se a matrícula falhar
        @school = current_user.school
        @students = @school.students.active
        @classrooms = @school.classrooms
        flash.now[:error] = "Erro ao criar matrícula: #{@enrollment.errors.full_messages.join(', ')}"
        render :new
      end
    else
      @school = current_user.school
      @students = @school.students.active
      @classrooms = @school.classrooms
      flash.now[:error] = "Erro ao criar estudante: #{@student.errors.full_messages.join(', ')}"
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
