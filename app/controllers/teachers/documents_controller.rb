class Teachers::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_document, only: [ :show, :edit, :update, :destroy, :download ]

  def index
    @documents = Document.joins(:subject)
                        .where(subjects: { user_id: current_user.id })
                        .includes(:subject, :user)
                        .order(created_at: :desc)

    @my_documents = current_user.authored_documents
                               .where(school: current_user.school)
                               .order(created_at: :desc)
  end

  def show
  end

  def new
    @document = current_user.authored_documents.build
    @subjects = current_user.teacher_subjects
    @students = available_students
  end

  def edit
    @subjects = current_user.teacher_subjects
    @students = available_students
  end

  def create
    @document = current_user.authored_documents.build(document_params)
    @document.school = current_user.school

    if @document.save
      redirect_to teachers_document_path(@document), notice: "Documento criado com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = available_students
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to teachers_document_path(@document), notice: "Documento atualizado com sucesso."
    else
      @subjects = current_user.teacher_subjects
      @students = available_students
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to teachers_documents_path, notice: "Documento removido com sucesso."
  end

  def download
    # Sanitizar nome do arquivo para evitar path traversal
    safe_filename = File.basename(@document.attachment.filename.to_s)
    send_file @document.attachment.path,
              disposition: "attachment",
              filename: safe_filename
  end

  private

  def ensure_teacher!
    unless current_user&.teacher?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def set_document
    @document = Document.joins(:subject)
                       .where(subjects: { user_id: current_user.id })
                       .or(Document.where(user_id: current_user.id))
                       .find(params[:id])
  end

  def available_students
    classroom_ids = current_user.teacher_subjects.pluck(:classroom_id).uniq
    User.where(classroom_id: classroom_ids, user_type: "student")
        .distinct
  end

  def document_params
    params.require(:document).permit(:title, :description, :subject_id, :user_id, :attachment, :document_type)
  end
end
