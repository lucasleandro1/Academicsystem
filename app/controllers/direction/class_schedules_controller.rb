class Direction::ClassSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school
    @classrooms = Classroom.where(school: @school).includes(:class_schedules, :subjects)

    # Filtros
    if params[:classroom_id].present?
      @selected_classroom = Classroom.find(params[:classroom_id])
      @class_schedules = @selected_classroom.class_schedules
                                           .includes(:subject, :classroom)
                                           .order(:day_of_week, :start_time)
    else
      @class_schedules = ClassSchedule.joins(:classroom)
                                     .where(classrooms: { school: @school })
                                     .includes(:subject, :classroom)
                                     .order(:day_of_week, :start_time)
    end

    if params[:day_of_week].present?
      @class_schedules = @class_schedules.where(day_of_week: params[:day_of_week])
    end

    @days_of_week = [
      [ "Segunda-feira", 1 ],
      [ "Terça-feira", 2 ],
      [ "Quarta-feira", 3 ],
      [ "Quinta-feira", 4 ],
      [ "Sexta-feira", 5 ],
      [ "Sábado", 6 ]
    ]
  end

  def show
    @classroom = Classroom.find(params[:id])

    # Verificar se a turma pertence à escola do diretor
    unless @classroom.school == current_user.school
      redirect_to direction_class_schedules_path, alert: "Turma não encontrada."
      return
    end

    @class_schedules = @classroom.class_schedules
                                .includes(:subject)
                                .order(:day_of_week, :start_time)

    @schedule_grid = build_schedule_grid(@class_schedules)
  end

  def new
    @class_schedule = ClassSchedule.new
    @classrooms = Classroom.where(school: current_user.school)
    @subjects = Subject.joins(:classrooms).where(classrooms: { school: current_user.school }).distinct
  end

  def create
    @class_schedule = ClassSchedule.new(class_schedule_params)

    if @class_schedule.save
      redirect_to direction_class_schedules_path, notice: "Horário criado com sucesso."
    else
      @classrooms = Classroom.where(school: current_user.school)
      @subjects = Subject.joins(:classrooms).where(classrooms: { school: current_user.school }).distinct
      render :new
    end
  end

  def edit
    @class_schedule = ClassSchedule.find(params[:id])

    # Verificar se o horário pertence à escola do diretor
    unless @class_schedule.classroom.school == current_user.school
      redirect_to direction_class_schedules_path, alert: "Horário não encontrado."
      return
    end

    @classrooms = Classroom.where(school: current_user.school)
    @subjects = Subject.joins(:classrooms).where(classrooms: { school: current_user.school }).distinct
  end

  def update
    @class_schedule = ClassSchedule.find(params[:id])

    # Verificar se o horário pertence à escola do diretor
    unless @class_schedule.classroom.school == current_user.school
      redirect_to direction_class_schedules_path, alert: "Horário não encontrado."
      return
    end

    if @class_schedule.update(class_schedule_params)
      redirect_to direction_class_schedules_path, notice: "Horário atualizado com sucesso."
    else
      @classrooms = Classroom.where(school: current_user.school)
      @subjects = Subject.joins(:classrooms).where(classrooms: { school: current_user.school }).distinct
      render :edit
    end
  end

  def destroy
    @class_schedule = ClassSchedule.find(params[:id])

    # Verificar se o horário pertence à escola do diretor
    unless @class_schedule.classroom.school == current_user.school
      redirect_to direction_class_schedules_path, alert: "Horário não encontrado."
      return
    end

    @class_schedule.destroy
    redirect_to direction_class_schedules_path, notice: "Horário excluído com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def class_schedule_params
    params.require(:class_schedule).permit(:classroom_id, :subject_id, :day_of_week, :start_time, :end_time)
  end

  def build_schedule_grid(schedules)
    grid = {}

    (1..6).each do |day|
      grid[day] = schedules.select { |s| s.day_of_week == day }
                          .sort_by(&:start_time)
    end

    grid
  end
end
