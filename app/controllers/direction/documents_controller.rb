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

    # Paginação com Kaminari
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
    @teachers = current_user.school.users.where(user_type: "teacher")
    @students = current_user.school.users.where(user_type: "student")
    @classrooms = current_user.school.classrooms

    # Para anexar documentos para usuários específicos
    @target_user = User.find(params[:user_id]) if params[:user_id].present?
    if @target_user && @target_user.school_id != current_user.school_id
      @target_user = nil
    end
  end

  def create
    @document = Document.new(document_params)
    @document.school = current_user.school
    @document.user = current_user
    @document.attached_by = current_user

    # Se for anexo para usuário específico
    if params[:document][:target_user_id].present?
      target_user = User.find(params[:document][:target_user_id])
      if @document.can_be_attached_by?(current_user, target_user)
        @document.sharing_type = "specific_user"
        @document.recipient = target_user
      else
        @document.errors.add(:base, "Você não tem permissão para anexar documentos para este usuário.")
      end
    end

    if @document.save
      redirect_to direction_documents_path, notice: "Documento criado com sucesso."
    else
      @teachers = current_user.school.users.where(user_type: "teacher")
      @students = current_user.school.users.where(user_type: "student")
      @classrooms = current_user.school.classrooms
      render :new
    end
  end

  def edit
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
      return
    end

    @teachers = current_user.school.users.where(user_type: "teacher")
    @students = current_user.school.users.where(user_type: "student")
    @classrooms = current_user.school.classrooms
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
      @teachers = current_user.school.users.where(user_type: "teacher")
      @students = current_user.school.users.where(user_type: "student")
      @classrooms = current_user.school.classrooms
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

  def download
    @document = Document.find(params[:id])

    # Verificar se o documento pertence à escola do diretor
    unless @document.school == current_user.school
      redirect_to direction_documents_path, alert: "Documento não encontrado."
      return
    end

    if @document.attachment.attached?
      redirect_to rails_blob_path(@document.attachment, disposition: "attachment")
    else
      redirect_to direction_document_path(@document), alert: "Nenhum arquivo anexado a este documento."
    end
  end

  def attach_to_user
    @user = User.find(params[:user_id])
    unless @user.school_id == current_user.school_id
      redirect_to direction_documents_path, alert: "Usuário não encontrado ou não pertence à sua escola."
      return
    end

    @document = Document.new
    @document.recipient = @user
    @document.sharing_type = "specific_user"

    @teachers = current_user.school.users.where(user_type: "teacher")
    @students = current_user.school.users.where(user_type: "student")
    @classrooms = current_user.school.classrooms

    render :new
  end

  private


  def document_params
    params.require(:document).permit(:title, :description, :document_type, :attachment, :sharing_type, :classroom_id, :target_user_id)
  end
end
