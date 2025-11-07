class Students::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student
  before_action :set_document, only: [ :show, :download, :destroy ]

  def index
    # Buscar documentos que o estudante pode visualizar
    @documents = Document.joins(:school)
                        .where(school: current_user.school)
                        .select { |doc| doc.can_be_viewed_by?(current_user) }
                        .sort_by(&:created_at)
                        .reverse

    # Separar em documentos próprios e recebidos
    @my_documents = @documents.select { |doc| doc.user_id == current_user.id }
    @received_documents = @documents.select { |doc| doc.user_id != current_user.id }

    # Agrupamento por tipo de documento
    @documents_by_type = @documents.group_by(&:document_type)
                                  .transform_values(&:count)
  end

  def show
    unless @document.can_be_viewed_by?(current_user)
      redirect_to students_documents_path, alert: "Você não tem permissão para acessar este documento."
    end
  end

  def new
    @document = Document.new
    @document.user = current_user
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user
    @document.school = current_user.school
    @document.sharing_type = "specific_user"
    @document.recipient = current_user
    @document.attached_by = current_user

    if @document.save
      redirect_to students_documents_path, notice: "Documento adicionado com sucesso."
    else
      render :new
    end
  end

  def destroy
    # Aluno só pode excluir seus próprios documentos
    if @document.user_id == current_user.id
      @document.destroy
      redirect_to students_documents_path, notice: "Documento removido com sucesso."
    else
      redirect_to students_documents_path, alert: "Você não tem permissão para remover este documento."
    end
  end

  def download
    unless @document.can_be_viewed_by?(current_user)
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

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :attachment)
  end
end
