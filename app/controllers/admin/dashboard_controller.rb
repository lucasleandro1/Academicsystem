class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index; end

  private

  def authorize_superadmin!
    redirect_to root_path, alert: "Acesso não autorizado." unless current_user&.admin?
  end
end
