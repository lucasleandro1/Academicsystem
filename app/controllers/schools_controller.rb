class SchoolsController < ApplicationController
  before_action :set_school, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    @schools = School.all
  end

  def show; end

  def new
    @school = School.new
  end

  def create
    @school = School.new(school_params)
    if @school.save
      redirect_to @school, notice: "Escola criada com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @school.update(school_params)
      redirect_to @school, notice: "Escola atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_url, notice: "Escola deletada com sucesso."
  end

  private
  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :cnpj, :address, :phone, :logo)
  end
end
