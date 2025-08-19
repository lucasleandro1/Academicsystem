class Admin::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  def index
    @events = Event.includes(:school).all

    # Aplicar filtros de busca
    if params[:search].present?
      @events = @events.where("title ILIKE ? OR description ILIKE ?",
                             "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:school_id].present?
      @events = @events.where(school_id: params[:school_id])
    end

    @events = @events.order(event_date: :desc)
    @schools = School.order(:name)
  end

  def show
  end

  def new
    @event = Event.new
    @schools = School.order(:name)
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      # Se for um evento municipal (sem escola específica), criar para todas as escolas
      if params[:event][:is_municipal] == "1"
        School.find_each do |school|
          Event.create!(
            title: @event.title,
            description: @event.description,
            event_date: @event.event_date,
            event_type: @event.event_type,
            school: school,
            is_municipal: true
          )
        end
        @event.destroy # Remove o evento "template"
        redirect_to admin_events_path, notice: "Evento municipal criado para todas as escolas com sucesso."
      else
        redirect_to admin_events_path, notice: "Evento criado com sucesso."
      end
    else
      @schools = School.order(:name)
      render :new
    end
  end

  def edit
    @schools = School.order(:name)
  end

  def update
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: "Evento atualizado com sucesso."
    else
      @schools = School.order(:name)
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Evento excluído com sucesso."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :event_date, :event_type, :school_id, :is_municipal)
  end
end
