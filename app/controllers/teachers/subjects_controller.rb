class Teachers::SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @subjects = current_user.teacher_subjects
                           .includes(:classroom, :school)
                           .order("classrooms.name")
  end

  def show
    @subject = current_user.teacher_subjects.includes(:classroom, :students).find(params[:id])
    @students = @subject.students
    @recent_grades = @subject.grades.includes(:student).order(created_at: :desc).limit(10)
  end

  private
end
