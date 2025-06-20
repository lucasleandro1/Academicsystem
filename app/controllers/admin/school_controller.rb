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
    params.require(:school).permit(:nome, :cnpj, :endereco, :telefone, :logo)
  end

  def authorize_superadmin!
    redirect_to root_path, alert: "Acesso não autorizado." unless current_user&.superadmin?
  end
end
