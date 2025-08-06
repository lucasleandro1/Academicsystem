class Admin::DirectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    @directions = User.where(user_type: "direction").includes(:school)

    # Aplicar filtros de busca
    if params[:search].present?
      @directions = @directions.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
                                     "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:school_id].present?
      @directions = @directions.where(school_id: params[:school_id])
    end

    @directions = @directions.order(:first_name, :last_name)
    @schools = School.order(:name)
  end

  def new
    @direction = User.new(user_type: "direction")
    @schools = School.order(:name)

    # Pre-selecionar escola se passada por parâmetro
    if params[:school_id].present?
      @direction.school_id = params[:school_id]
    end
  end

  def create
    @direction = User.new(direction_params)
    @direction.user_type = "direction"
    @direction.password = SecureRandom.hex(8) if @direction.password.blank?

    if @direction.save
      redirect_to admin_directions_path, notice: "Diretor(a) criado(a) com sucesso."
    else
      @schools = School.order(:name)
      render :new
    end
  end

  def destroy
    @direction = User.find(params[:id])
    @direction.destroy
    redirect_to admin_directions_path, notice: "Diretor(a) removido(a) com sucesso."
  end

  private

  def direction_params
    params.require(:user).permit(
      :email, :password, :school_id, :first_name, :last_name, :phone,
      :registration_number, :birth_date, :position
    )
  end
end
