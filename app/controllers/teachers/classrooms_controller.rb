class Teachers::ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @classrooms = current_user.teacher_subjects
                             .joins(:classroom)
                             .includes(classroom: [ :school ])
                             .distinct
                             .map(&:classroom)
  end

  def show
    @classroom = Classroom.joins(:subjects)
                         .where(subjects: { user_id: current_user.id })
                         .find(params[:id])
    @subjects = @classroom.subjects.where(user_id: current_user.id)
    @students = @classroom.students
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
