class TestController < ActionController::Base
  protect_from_forgery with: :exception

  def users
    @users = User.all.includes(:school)
  end

  def login_as
    user = User.find(params[:id])
    sign_in(user)
    redirect_to root_path, notice: "Logado como #{user.full_name} (#{user.user_type})"
  end
end
