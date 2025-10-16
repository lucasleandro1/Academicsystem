class Students::SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    return redirect_to students_root_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    @subjects = current_user.classroom.subjects.includes(:user, :classroom, class_schedules: :classroom)
    @current_semester = determine_current_semester
    @academic_year = Date.current.year
  end

  def show
    @subject = Subject.find(params[:id])

    # Verificar se o estudante tem acesso a esta disciplina
    unless current_user.classroom&.subjects&.include?(@subject)
      redirect_to students_subjects_path, alert: "Você não tem acesso a esta disciplina."
      return
    end

    # Buscar informações da disciplina
    @teacher = @subject.user
    @classroom = @subject.classroom
    @class_schedules = ClassSchedule.where(subject: @subject)
                                  .includes(:classroom)
                                  .order(:weekday, :start_time)

    # Estatísticas básicas
    @total_classes = @class_schedules.count * 4 # Estimativa baseada em 4 semanas por mês
    @attendance_rate = calculate_attendance_rate(@subject)
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end

  def determine_current_semester
    current_month = Date.current.month
    case current_month
    when 1..6
      1
    when 7..12
      2
    else
      1
    end
  end

  def calculate_attendance_rate(subject)
    # Esta é uma implementação básica - você pode refinar baseado no seu modelo de dados
    total_classes = 20 # Valor padrão
    absences = Absence.where(
      user: current_user,
      subject: subject,
      date: Date.current.beginning_of_year..Date.current.end_of_year
    ).count

    present_classes = [ total_classes - absences, 0 ].max
    return 0 if total_classes.zero?

    (present_classes.to_f / total_classes * 100).round(1)
  end
end
