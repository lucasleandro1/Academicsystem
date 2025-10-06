class Direction::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  def index
    @events = current_user.school.events.order(:start_date)
  end

  def show
  end

  def new
    @event = current_user.school.events.build
  end

  def edit
  end

  def create
    @event = current_user.school.events.build(event_params)

    if @event.save
      redirect_to direction_event_path(@event), notice: "Evento criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      redirect_to direction_event_path(@event), notice: "Evento atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to direction_events_path, notice: "Evento removido com sucesso."
  end

  private


  def set_event
    @event = current_user.school.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_date, :end_date, :start_time, :end_time, :event_type)
  end
end
