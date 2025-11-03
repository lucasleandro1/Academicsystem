class Students::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student
  before_action :set_document, only: [ :show, :download ]

  def index
    # Buscar documentos compartilhados com este estudante
    @documents = Document.joins(:school)
                        .where(school: current_user.school)
                        .select { |doc| doc.shared_with_student?(current_user) }
                        .sort_by(&:created_at)
                        .reverse

    # Agrupamento por tipo de documento
    @documents_by_type = @documents.group_by(&:document_type)
                                  .transform_values(&:count)
  end

  def show
    unless @document.shared_with_student?(current_user)
      redirect_to students_documents_path, alert: "Você não tem permissão para acessar este documento."
    end
  end

  def download
    unless @document.shared_with_student?(current_user)
      redirect_to students_documents_path, alert: "Você não tem permissão para baixar este documento."
      return
    end

    if @document.attachment.attached?
      send_data @document.attachment.download,
                filename: @document.attachment.filename.to_s,
                type: @document.attachment.content_type,
                disposition: "attachment"
    elsif @document.file_path.present? && File.exist?(@document.file_path)
      send_file @document.file_path,
                filename: File.basename(@document.file_path),
                disposition: "attachment"
    else
      redirect_to students_documents_path, alert: "Arquivo não encontrado."
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def ensure_student
    redirect_to root_path unless current_user.student?
  end
end
