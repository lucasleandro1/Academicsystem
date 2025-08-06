class Students::AbsencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    @absences = current_user.absences.includes(:subject)
                           .order(date: :desc)

    # Resumo de faltas por disciplina
    @absence_summary = @absences.group(:subject_id).group(:justified).count
                                .each_with_object({}) do |((subject_id, justified), count), hash|
      hash[subject_id] ||= { total: 0, justified: 0, unjustified: 0 }
      hash[subject_id][:total] += count
      if justified
        hash[subject_id][:justified] += count
      else
        hash[subject_id][:unjustified] += count
      end
    end
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
