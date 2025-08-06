class Direction::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school
    @documents = Document.where(school: @school)
                        .includes(:user)
                        .order(created_at: :desc)

    # Filtros
    if params[:search].present?
      @documents = @documents.where("title ILIKE ? OR description ILIKE ?",
                                   "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:document_type].present?
      @documents = @documents.where(document_type: params[:document_type])
    end

    if params[:user_type].present?
      @documents = @documents.joins(:user).where(users: { user_type: params[:user_type] })
    end

    @documents = @documents.page(params[:page]).per(20)
    @document_types = Document.distinct.pluck(:document_type).compact
  end

  def show
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
    end
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.school = current_user.school
    @document.user = current_user

    if @document.save
      redirect_to direction_documents_path, notice: "Documento criado com sucesso."
    else
      render :new
    end
  end

  def edit
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
    end
  end

  def update
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
      return
    end

    if @document.update(document_params)
      redirect_to direction_document_path(@document), notice: "Documento atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
      return
    end

    @document.destroy
    redirect_to direction_documents_path, notice: "Documento excluído com sucesso."
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :file, :active)
  end
end
