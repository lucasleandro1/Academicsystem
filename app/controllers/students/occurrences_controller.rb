class Students::OccurrencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    @occurrences = current_user.occurrences.includes(:subject)
                              .order(date: :desc)

    # Estatísticas de ocorrências
    @occurrences_by_type = @occurrences.group(:occurrence_type).count
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
