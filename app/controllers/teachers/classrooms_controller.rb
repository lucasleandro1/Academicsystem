class Teachers::ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @classrooms = current_user.teacher_classrooms.includes(:school)
  end

  def show
    @classroom = current_user.teacher_classrooms.find(params[:id])
    @subjects = Subject.joins(:class_schedules)
                       .where(class_schedules: { classroom_id: @classroom.id, subject_id: current_user.teacher_subjects.ids })
                       .distinct
    @students = @classroom.students
  end

  private
end
