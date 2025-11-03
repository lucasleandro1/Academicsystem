class Direction::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  def index
    @events = current_user.school.events

    # Por padrão, mostrar apenas eventos não concluídos
    # Só mostra concluídos se filtrado explicitamente
    if params[:status].present?
      case params[:status]
      when "planned"
        @events = @events.where("COALESCE(start_date, event_date) > ?", Date.current)
      when "ongoing"
        @events = @events.where("COALESCE(start_date, event_date) = ?", Date.current)
      when "completed"
        @events = @events.where("COALESCE(start_date, event_date) < ?", Date.current)
      end
    else
      # Por padrão: eventos futuros e de hoje (não mostrar concluídos)
      @events = @events.where("COALESCE(start_date, event_date) >= ?", Date.current)
    end

    # Aplicar outros filtros
    if params[:search].present?
      @events = @events.where("title ILIKE ? OR description ILIKE ?",
                             "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:event_type].present?
      @events = @events.where(event_type: params[:event_type])
    end

    if params[:start_date].present?
      @events = @events.where("COALESCE(start_date, event_date) >= ?", params[:start_date])
    end

    if params[:end_date].present?
      @events = @events.where("COALESCE(start_date, event_date) <= ?", params[:end_date])
    end

    @events = @events.order(Arel.sql("COALESCE(start_date, event_date) ASC"))
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
