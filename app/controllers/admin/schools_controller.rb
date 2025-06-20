class Admin::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def new
    @school = School.new
  end

  def create
    @school = School.new(school_params)
    if @school.save
      redirect_to admin_root_path, notice: "Escola criada com sucesso."
    else
      render :new
    end
  end

  private

  def school_params
    params.require(:school).permit(:name, :cnpj, :address, :phone, :logo)
  end
end
