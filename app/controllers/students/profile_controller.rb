class Students::ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def show
    @user = current_user
    @classroom = @user.classroom
    @school = current_user.school
  end

  def edit
    @student = current_user
  end

  def update
    @student = current_user
    if @student.update(student_params)
      redirect_to students_profile_path, notice: "Perfil atualizado com sucesso."
    else
      render :edit
    end
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def student_params
    params.require(:user).permit(:first_name, :last_name, :phone, :birth_date, :guardian_name)
  end
end
