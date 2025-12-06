class Students::CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_student!

  def index
    # Definir o mês e ano atual ou baseado nos parâmetros
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @current_month = @current_date.beginning_of_month
    @current_year = @current_date.year

    # Buscar eventos do mês atual baseado no tipo de usuário
    month_start = @current_month.beginning_of_month
    month_end = @current_month.end_of_month

    @calendars = build_calendar_query(month_start, month_end)

    # Aplicar filtros
    if params[:search].present?
      @calendars = @calendars.where("title ILIKE ? OR description ILIKE ?",
                                  "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:calendar_type].present?
      @calendars = @calendars.where(calendar_type: params[:calendar_type])
    end

    @calendars = @calendars.order(:date)

    # Buscar eventos municipais do mês
    @events = build_events_query(month_start, month_end)
    
    # Aplicar filtros aos eventos
    if params[:search].present?
      @events = @events.where("title ILIKE ? OR description ILIKE ?",
                             "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Agrupar eventos por data para facilitar a exibição no calendário
    @events_by_date = @calendars.group_by(&:date)
    @municipal_events_by_date = @events.group_by { |e| e.start_date || e.event_date }

    # Dados para os filtros
    @calendar_types = Calendar::CALENDAR_TYPES

    # Calcular navegação do calendário
    @prev_month = @current_month - 1.month
    @next_month = @current_month + 1.month

    # Estatísticas do mês
    @month_stats = {
      total_events: @calendars.count + @events.count,
      holidays: @calendars.where(calendar_type: [ "holiday", "municipal_holiday" ]).count,
      vacations: @calendars.where(calendar_type: "vacation").count,
      school_events: @calendars.where(calendar_type: [ "school_start", "school_end" ]).count + @events.count
    }
  end

  private

  def build_calendar_query(month_start, month_end)
    calendars = Calendar.includes(:school).where(date: month_start..month_end)

    if current_user.school_id.present?
      calendars.where(
        "(all_schools = ? OR school_id = ?)",
        true, current_user.school_id
      )
    else
      # Estudante sem escola vê apenas eventos municipais
      calendars.where(all_schools: true)
    end
  end

  def build_events_query(month_start, month_end)
    events = Event.includes(:school).where(
      "COALESCE(start_date, event_date) >= ? AND COALESCE(start_date, event_date) <= ?",
      month_start, month_end
    )

    if current_user.school_id.present?
      events.where(
        "(is_municipal = ? OR school_id = ?)",
        true, current_user.school_id
      )
    else
      # Estudante sem escola vê apenas eventos municipais
      events.where(is_municipal: true)
    end
  end
end
