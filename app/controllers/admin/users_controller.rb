class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_root_path, notice: "Usuário criado com sucesso."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :user_type, :school_id, :active)
  end
end
