class Teachers::ClassSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    @subjects = current_user.subjects.includes(:classroom, :class_schedules)
    @schedules_by_subject = {}

    @subjects.each do |subject|
      schedules = subject.class_schedules
                        .group_by(&:weekday)
                        .transform_values { |schedules| schedules.sort_by(&:start_time) }

      @schedules_by_subject[subject] = schedules
    end
  end

  def show
    @subject = current_user.subjects.find(params[:id])
    @schedules = @subject.class_schedules
                        .group_by(&:weekday)
                        .transform_values { |schedules| schedules.sort_by(&:start_time) }
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
