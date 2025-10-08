class Teachers::ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @classrooms = current_user.teacher_classrooms.includes(:school)
  end

  def show
    @classroom = current_user.teacher_classrooms.find(params[:id])
    @subjects = @classroom.subjects.where(user_id: current_user.id)
    @students = @classroom.students
  end

  private
end
