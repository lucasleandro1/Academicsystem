class Direction::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def show
    @school = current_user.school
  end

  def edit
    @school = current_user.school
  end

  def update
    @school = current_user.school
    if @school.update(school_params)
      redirect_to direction_school_path, notice: "Dados da escola atualizados com sucesso."
    else
      render :edit
    end
  end

  private


  def school_params
    params.require(:school).permit(:name, :cnpj, :address, :phone, :description, :logo)
  end
end
