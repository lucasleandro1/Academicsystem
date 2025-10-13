class Students::ClassSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    unless current_user.classroom
      redirect_to students_root_path, alert: "Você não está matriculado em nenhuma turma."
      return
    end

    # Buscar horários diretamente da turma do aluno
    @schedules = current_user.classroom.class_schedules.includes(:subject, :classroom)



    # Verificar se há horários cadastrados
    unless @schedules.any?
      flash.now[:info] = "Sua turma ainda não possui horários cadastrados. Entre em contato com a coordenação."
    end

    # Extrair disciplinas únicas dos horários
    @subjects = @schedules.map(&:subject).uniq.compact
    @current_subjects = @subjects # Alias para compatibilidade com a view

    # Horários para diferentes períodos
    current_weekday = Date.current.wday
    @today_classes = @schedules.where(weekday: current_weekday)

    # Horários da semana atual (todos os horários, já que são recorrentes)
    @week_classes = @schedules
    @week_schedule = @schedules # Alias para compatibilidade

    # Mapeamento de dias da semana (0=domingo, 1=segunda, etc.)
    weekday_map = {
      1 => "monday",
      2 => "tuesday",
      3 => "wednesday",
      4 => "thursday",
      5 => "friday",
      6 => "saturday",
      0 => "sunday"
    }

    # Organizar horários por dia e horário para a grade de horários
    @schedules_by_day_time = {}
    @time_slots = Set.new

    @schedules.each do |schedule|
      day_name = weekday_map[schedule.weekday]
      time_slot = "#{schedule.start_time.strftime('%H:%M')} - #{schedule.end_time.strftime('%H:%M')}"

      @schedules_by_day_time[day_name] ||= {}
      @schedules_by_day_time[day_name][time_slot] = schedule
      @time_slots.add(time_slot)
    end

    @time_slots = @time_slots.to_a.sort
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
