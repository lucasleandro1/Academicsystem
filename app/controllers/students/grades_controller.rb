class Students::GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @enrollments = current_user.enrollments.includes(classroom: :subjects)
    @grades_by_subject = {}

    @enrollments.each do |enrollment|
      enrollment.classroom.subjects.each do |subject|
        @grades_by_subject[subject] = current_user.grades
                                                  .where(subject: subject)
                                                  .group(:bimester)
                                                  .average(:value)
      end
    end
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
