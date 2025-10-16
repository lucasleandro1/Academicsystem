class Admin::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!
  before_action :set_document, only: [ :show, :edit, :update, :destroy, :download ]

  def index
    @documents = Document.includes(:school).all

    # Aplicar filtros de busca
    if params[:search].present?
      @documents = @documents.where("title ILIKE ? OR description ILIKE ? OR file_name ILIKE ?",
                                   "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:document_type].present?
      @documents = @documents.where(document_type: params[:document_type])
    end

    if params[:school_id].present?
      @documents = @documents.where(school_id: params[:school_id])
    end

    @documents = @documents.order(created_at: :desc)
    @schools = School.order(:name)
    @document_types = Document.distinct.pluck(:document_type).compact.sort
  end

  def show
  end

  def new
    @document = Document.new
    @schools = School.order(:name)
  end

  def create
    @document = Document.new(document_params)

    # Processar upload de arquivo se presente
    if params[:document][:file].present?
      uploaded_file = params[:document][:file]
      @document.file_name = uploaded_file.original_filename

      # Criar diretório se não existir
      upload_dir = Rails.root.join("storage", "documents")
      FileUtils.mkdir_p(upload_dir) unless Dir.exist?(upload_dir)

      # Salvar arquivo com nome único
      original_filename = uploaded_file.original_filename.to_s
      file_extension = File.extname(original_filename).downcase
      # Validar extensão do arquivo
      allowed_extensions = %w[.pdf .doc .docx .txt .jpg .jpeg .png .gif]
      unless allowed_extensions.include?(file_extension)
        @document.errors.add(:file, "Tipo de arquivo não permitido")
        render :new and return
      end

      unique_filename = "#{SecureRandom.uuid}#{file_extension}"
      file_path = upload_dir.join(unique_filename)

      File.open(file_path, "wb") do |file|
        file.write(uploaded_file.read)
      end

      @document.file_path = file_path.to_s
    end

    if @document.save
      # Se for um documento municipal (para todas as escolas)
      if params[:document][:is_municipal] == "1" || @document.is_municipal
        School.find_each do |school|
          Document.create!(
            title: @document.title,
            description: @document.description,
            document_type: @document.document_type,
            file_path: @document.file_path,
            file_name: @document.file_name,
            school: school,
            user_id: @document.user_id,
            is_municipal: true
          )
        end
        @document.destroy # Remove o documento "template"
        redirect_to admin_documents_path, notice: "Documento municipal disponibilizado para todas as escolas com sucesso."
      else
        redirect_to admin_documents_path, notice: "Documento criado com sucesso."
      end
    else
      @schools = School.order(:name)
      render :new
    end
  end

  def edit
    @schools = School.order(:name)
  end

  def update
    if @document.update(document_params)
      redirect_to admin_document_path(@document), notice: "Documento atualizado com sucesso."
    else
      @schools = School.order(:name)
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to admin_documents_path, notice: "Documento excluído com sucesso."
  end

  def download
    if @document.attachment.attached?
      redirect_to rails_blob_path(@document.attachment, disposition: "attachment")
    elsif @document.file_path.present? && File.exist?(@document.file_path)
      # Sanitizar nome do arquivo para evitar path traversal
      safe_filename = File.basename(@document.file_name)
      send_file @document.file_path, filename: safe_filename, type: "application/octet-stream"
    else
      redirect_to admin_documents_path, alert: "Arquivo não encontrado."
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :attachment, :file_path, :file_name, :school_id, :user_id, :is_municipal)
  end
end
