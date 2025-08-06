class Admin::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!
  before_action :set_school, only: [ :show, :edit, :update, :destroy ]

  def index
    @schools = School.all

    # Aplicar filtros de busca
    if params[:search].present?
      @schools = @schools.where("name ILIKE ? OR cnpj ILIKE ? OR address ILIKE ?",
                               "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @schools = @schools.order(:name)
  end

  def show
  end

  def new
    @school = School.new
  end

  def create
    @school = School.new(school_params)
    if @school.save
      redirect_to admin_schools_path, notice: "Escola criada com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @school.update(school_params)
      redirect_to admin_school_path(@school), notice: "Escola atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @school.destroy
    redirect_to admin_schools_path, notice: "Escola excluída com sucesso."
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :cnpj, :address, :phone, :logo)
  end
end
