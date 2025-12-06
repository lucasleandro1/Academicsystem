class Teachers::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!

  def index
    # Verificar se o usuário tem escola associada
    unless current_user.school
      redirect_to teachers_root_path, alert: "Você não está associado a nenhuma escola."
      return
    end

    @events = current_user.school.events

    # Aplicar filtros baseados nos parâmetros
    if params[:period].present?
      case params[:period]
      when "week"
        @events = @events.where(start_date: Date.current..Date.current + 7.days)
      when "month"
        @events = @events.where(start_date: Date.current..Date.current + 30.days)
      when "current_month"
        @events = @events.where(start_date: Date.current.beginning_of_month..Date.current.end_of_month)
      when "past"
        @events = @events.where("end_date < ?", Date.current)
      else
        # 'all' ou sem filtro - mostrar futuros por padrão
        @events = @events.where("start_date >= ?", Date.current) unless params[:period] == "all"
      end
    else
      # Por padrão, mostrar apenas eventos futuros
      @events = @events.where("start_date >= ?", Date.current)
    end

    # Filtro por tipo (mapear de inglês para português)
    if params[:type].present?
      type_mapping = {
        "academic" => "academico",
        "cultural" => "cultural",
        "sports" => "esportivo",
        "meeting" => "reuniao",
        "holiday" => "feriado"
      }
      mapped_type = type_mapping[params[:type]] || params[:type]
      @events = @events.where(event_type: mapped_type)
    end

    # Filtro por busca
    if params[:search].present?
      @events = @events.where("title ILIKE ? OR description ILIKE ?",
                              "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Ordenar por data
    @events = @events.order(:start_date)

    # Manter as variáveis originais para compatibilidade
    @upcoming_events = current_user.school.events
                                  .where("start_date >= ?", Date.current)
                                  .order(:start_date)

    @past_events = current_user.school.events
                              .where("end_date < ?", Date.current)
                              .order(start_date: :desc)
                              .limit(10)
  end

  def show
    unless current_user.school
      redirect_to teachers_root_path, alert: "Você não está associado a nenhuma escola."
      return
    end

    @event = current_user.school.events.find(params[:id])
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
