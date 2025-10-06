class Students::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    @upcoming_events = current_user.school.events
                                  .where("start_date >= ?", Date.current)
                                  .order(:start_date)

    @past_events = current_user.school.events
                              .where("end_date < ?", Date.current)
                              .order(start_date: :desc)
                              .limit(10)
  end

  def show
    @event = current_user.school.events.find(params[:id])
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
