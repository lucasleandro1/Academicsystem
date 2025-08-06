class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    @schools = School.includes(:users)
    @total_schools = @schools.count
    @total_users = User.count
    @total_students = User.student.count
    @total_teachers = User.teacher.count
    @total_directions = User.direction.count
  end
end
