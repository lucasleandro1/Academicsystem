class Admin::CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!
  before_action :set_calendar, only: [ :show, :edit, :update, :destroy ]

  def index
    # Definir o mês e ano atual ou baseado nos parâmetros
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @current_month = @current_date.beginning_of_month
    @current_year = @current_date.year

    # Buscar eventos do mês atual
    month_start = @current_month.beginning_of_month
    month_end = @current_month.end_of_month

    @calendars = Calendar.includes(:school)
                        .where(date: month_start..month_end)

    # Aplicar filtros
    if params[:search].present?
      @calendars = @calendars.where("title ILIKE ? OR description ILIKE ?",
                                  "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:calendar_type].present?
      @calendars = @calendars.where(calendar_type: params[:calendar_type])
    end

    if params[:school_id].present?
      @calendars = @calendars.where(school_id: params[:school_id])
    end

    @calendars = @calendars.order(:date)

    # Buscar eventos municipais do mês
    @events = Event.includes(:school).where(
      "COALESCE(start_date, event_date) >= ? AND COALESCE(start_date, event_date) <= ?",
      month_start, month_end
    )
    
    # Aplicar filtros aos eventos
    if params[:search].present?
      @events = @events.where("title ILIKE ? OR description ILIKE ?",
                             "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:school_id].present?
      @events = @events.where(school_id: params[:school_id])
    end

    # Agrupar eventos por data para facilitar a exibição no calendário
    @events_by_date = @calendars.group_by(&:date)
    @municipal_events_by_date = @events.group_by { |e| e.start_date || e.event_date }

    # Dados para os filtros
    @schools = School.order(:name)
    @calendar_types = Calendar::CALENDAR_TYPES

    # Calcular navegação do calendário
    @prev_month = @current_month - 1.month
    @next_month = @current_month + 1.month

    # Estatísticas do mês
    @month_stats = {
      total_events: @calendars.count + @events.count,
      holidays: @calendars.where(calendar_type: "holiday").count,
      vacations: @calendars.where(calendar_type: "vacation").count,
      municipal_events: @calendars.municipal.count + @events.where(is_municipal: true).count
    }
  end

  def municipal
    @calendars = Calendar.municipal.order(:date)
    render :index
  end

  def show
  end

  def new
    @calendar = Calendar.new

    # Pré-definir valores baseados nos parâmetros
    if params[:date].present?
      @calendar.date = Date.parse(params[:date]) rescue Date.current
    end

    if params[:calendar_type].present? && Calendar::CALENDAR_TYPES.include?(params[:calendar_type])
      @calendar.calendar_type = params[:calendar_type]
    end

    @schools = School.order(:name)
    @calendar_types = Calendar::CALENDAR_TYPES
  end

  def create
    @calendar = Calendar.new(calendar_params)

    if @calendar.save
      # Se for um evento municipal (para todas as escolas)
      if @calendar.all_schools?
        School.find_each do |school|
          Calendar.create!(
            title: @calendar.title,
            description: @calendar.description,
            date: @calendar.date,
            calendar_type: @calendar.calendar_type,
            school: school,
            all_schools: false # Cópias específicas para cada escola
          )
        end
        redirect_to admin_calendars_path,
                    notice: "Evento municipal adicionado ao calendário de todas as escolas com sucesso."
      else
        redirect_to admin_calendars_path,
                    notice: "Evento adicionado ao calendário com sucesso."
      end
    else
      @schools = School.order(:name)
      @calendar_types = Calendar::CALENDAR_TYPES
      render :new
    end
  end

  def edit
    @schools = School.order(:name)
    @calendar_types = Calendar::CALENDAR_TYPES
  end

  def update
    if @calendar.update(calendar_params)
      redirect_to admin_calendar_path(@calendar),
                  notice: "Evento do calendário atualizado com sucesso."
    else
      @schools = School.order(:name)
      @calendar_types = Calendar::CALENDAR_TYPES
      render :edit
    end
  end

  def destroy
    if @calendar.municipal?
      # Se for municipal, remove também as cópias das escolas
      Calendar.where(
        title: @calendar.title,
        date: @calendar.date,
        calendar_type: @calendar.calendar_type,
        all_schools: false
      ).destroy_all
    end

    @calendar.destroy
    redirect_to admin_calendars_path,
                notice: "Evento removido do calendário com sucesso."
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:id])
  end

  def calendar_params
    params.require(:calendar).permit(:title, :description, :date, :calendar_type, :school_id, :all_schools)
  end
end
