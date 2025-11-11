class CalendarsController < ApplicationController
  before_action :authenticate_user!

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

    # Agrupar eventos por data para facilitar a exibição no calendário
    @events_by_date = @calendars.group_by(&:date)

    # Dados para os filtros
    @calendar_types = Calendar::CALENDAR_TYPES

    # Calcular navegação do calendário
    @prev_month = @current_month - 1.month
    @next_month = @current_month + 1.month

    # Estatísticas do mês
    @month_stats = {
      total_events: @calendars.count,
      holidays: @calendars.where(calendar_type: [ "holiday", "municipal_holiday" ]).count,
      vacations: @calendars.where(calendar_type: "vacation").count,
      school_events: @calendars.where(calendar_type: [ "school_start", "school_end" ]).count
    }
  end

  private

  def build_calendar_query(month_start, month_end)
    calendars = Calendar.includes(:school).where(date: month_start..month_end)

    case current_user.user_type
    when "admin"
      # Admin pode ver todos os calendários
      calendars
    when "direction"
      # Diretor pode ver eventos municipais e da sua escola
      if current_user.school_id.present?
        calendars.where(
          "(all_schools = ? OR school_id = ?)",
          true, current_user.school_id
        )
      else
        # Diretor sem escola vê apenas eventos municipais
        calendars.where(all_schools: true)
      end
    when "teacher", "student"
      # Professor e estudante podem ver eventos municipais e da sua escola
      if current_user.school_id.present?
        calendars.where(
          "(all_schools = ? OR school_id = ?)",
          true, current_user.school_id
        )
      else
        # Usuário sem escola vê apenas eventos municipais
        calendars.where(all_schools: true)
      end
    else
      calendars.none
    end
  end
end
