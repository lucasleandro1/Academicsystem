class Students::GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    return redirect_to students_dashboard_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    @grade_types = [ "1º Bimestre", "2º Bimestre", "3º Bimestre", "4º Bimestre" ]

    @grades_by_subject = {}
    if current_user.classroom&.class_schedules&.any?
      # Buscar disciplinas através dos horários da turma
      subjects_from_schedules = current_user.classroom.class_schedules.includes(:subject).map(&:subject).uniq
      subjects_from_schedules.each do |subject|
        @grades_by_subject[subject] = current_user.student_grades
                                                  .where(subject: subject)
                                                  .group(:bimester)
                                                  .average(:value)
      end
    end

    # Calcular média geral usando as disciplinas dos horários
    subject_ids = current_user.classroom&.class_schedules&.pluck(:subject_id) || []
    all_grades = current_user.student_grades.where(subject_id: subject_ids)
    @overall_average = all_grades.any? ? all_grades.average(:value).round(1) : nil
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
