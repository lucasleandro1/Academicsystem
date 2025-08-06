class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.includes(:school).all

    # Aplicar filtros de busca
    if params[:search].present?
      @users = @users.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR registration_number ILIKE ?",
                           "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:user_type].present?
      @users = @users.where(user_type: params[:user_type])
    end

    if params[:school_id].present?
      @users = @users.where(school_id: params[:school_id])
    end

    @users = @users.order(:first_name, :last_name)
    @schools = School.order(:name)
  end

  def show
  end

  def new
    @user = User.new
    @schools = School.order(:name)
  end

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex(8) if @user.password.blank?

    if @user.save
      redirect_to admin_users_path, notice: "Usuário criado com sucesso."
    else
      @schools = School.order(:name)
      render :new
    end
  end

  def edit
    @schools = School.order(:name)
  end

  def update
    if @user.update(user_params_for_update)
      redirect_to admin_user_path(@user), notice: "Usuário atualizado com sucesso."
    else
      @schools = School.order(:name)
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "Usuário excluído com sucesso."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :school_id, :user_type,
      :registration_number, :birth_date, :guardian_name,
      :position, :specialization, :first_name, :last_name, :phone
    )
  end

  def user_params_for_update
    permitted_params = user_params
    permitted_params.delete(:password) if permitted_params[:password].blank?
    permitted_params
  end
end
