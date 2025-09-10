class Students::ClassSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    return redirect_to students_dashboard_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    @subjects = current_user.classroom.subjects
    @schedules = ClassSchedule.joins(:subject)
                             .where(subjects: { classroom_id: current_user.classroom.id })
                             .includes(:subject, :classroom)

    # Organizar horários por dia e horário
    @schedules_by_day_time = {}
    @time_slots = Set.new

    @schedules.each do |schedule|
      day = schedule.weekday
      time_slot = "#{schedule.start_time.strftime('%H:%M')} - #{schedule.end_time.strftime('%H:%M')}"

      @schedules_by_day_time[day] ||= {}
      @schedules_by_day_time[day][time_slot] = schedule
      @time_slots.add(time_slot)
    end

    @time_slots = @time_slots.to_a.sort
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
