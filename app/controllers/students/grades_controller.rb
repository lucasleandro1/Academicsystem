class Students::GradesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def index
    return redirect_to students_dashboard_path, alert: "Você não está em nenhuma turma." unless current_user.classroom

    @grade_types = [ "1º Bimestre", "2º Bimestre", "3º Bimestre", "4º Bimestre" ]

    @grades_by_subject = {}
    if current_user.classroom&.subjects&.any?
      current_user.classroom.subjects.each do |subject|
        @grades_by_subject[subject] = current_user.grades
                                                  .where(subject: subject)
                                                  .group(:bimester)
                                                  .average(:value)
      end
    end

    # Calcular média geral
    all_grades = current_user.grades.where(subject: current_user.classroom&.subjects)
    @overall_average = all_grades.any? ? all_grades.average(:value) : nil
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
