class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index; end
end
