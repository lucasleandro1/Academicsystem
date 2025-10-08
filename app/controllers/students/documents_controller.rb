class Students::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student

  def index
    @documents = Document.where(user_id: current_user.id)
                        .order(created_at: :desc)

    # Agrupamento por tipo de documento
    @documents_by_type = @documents.group(:document_type).count
  end

  private

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
