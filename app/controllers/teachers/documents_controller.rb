class Teachers::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
  before_action :set_document, only: [ :show, :edit, :update, :destroy, :download ]

  def index
    # Get all documents from the teacher's school that they can view
    @documents = Document.where(school: current_user.school)
                        .includes(:user, :subject, :recipient)
                        .select { |doc| doc.can_be_viewed_by?(current_user) }
                        .sort_by(&:created_at)
                        .reverse

    @my_documents = current_user.teacher_documents
                               .where(school: current_user.school)
                               .includes(:subject, :recipient)
                               .order(created_at: :desc)

    # Documentos anexados para meus alunos
    my_student_ids = available_students.pluck(:id)
    @documents_for_students = Document.where(
      school: current_user.school,
      recipient_type: "User",
      recipient_id: my_student_ids
    ).includes(:recipient, :user).order(created_at: :desc)
  end

  def show
  end

  def new
    @document = current_user.authored_documents.build
    @subjects = grouped_subjects_for_select
    @students = available_students
    @classrooms = available_classrooms

    # Debug: verificar se há alunos disponíveis
    Rails.logger.info "=== DEBUG: Alunos disponíveis para #{current_user.full_name}: #{@students.count} ==="
    
    # Para anexar documentos para alunos específicos
    @target_student = User.find(params[:student_id]) if params[:student_id].present?
    if @target_student && !@target_student.student?
      @target_student = nil
    end
  end

  def edit
    @subjects = grouped_subjects_for_select
    @students = available_students
    @classrooms = available_classrooms
  end

  def create
    @document = current_user.authored_documents.build(document_params)
    @document.school = current_user.school
    @document.attached_by = current_user

    # Se for anexo para aluno específico
    if params[:document][:target_student_id].present?
      target_student = User.find(params[:document][:target_student_id])
      if @document.can_be_attached_by?(current_user, target_student)
        @document.sharing_type = "specific_user"
        @document.recipient = target_student
      else
        @document.errors.add(:base, "Você não tem permissão para anexar documentos para este aluno.")
      end
    end

    if @document.save
      redirect_to teachers_document_path(@document), notice: "Documento criado com sucesso."
    else
      @subjects = grouped_subjects_for_select
      @students = available_students
      @classrooms = available_classrooms
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to teachers_document_path(@document), notice: "Documento atualizado com sucesso."
    else
      @subjects = grouped_subjects_for_select
      @students = available_students
      @classrooms = available_classrooms
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to teachers_documents_path, notice: "Documento removido com sucesso."
  end

  def attach_to_student
    @student = User.find(params[:student_id])
    unless @student.student? && available_students.include?(@student)
      redirect_to teachers_documents_path, alert: "Aluno não encontrado ou não pertence às suas turmas."
      return
    end

    @document = current_user.authored_documents.build
    @document.recipient = @student
    @document.sharing_type = "specific_user"

    render :new
  end

  def download
    if @document.attachment.attached?
      # Active Storage attachment - redirect to rails blob path
      redirect_to rails_blob_path(@document.attachment, disposition: "attachment")
    elsif @document.file_path.present? && File.exist?(@document.file_path)
      # Legacy file_path system
      safe_filename = File.basename(@document.file_name || "document")
      send_file @document.file_path,
                disposition: "attachment",
                filename: safe_filename
    else
      redirect_to teachers_documents_path, alert: "Arquivo não encontrado."
    end
  end

  private

  def set_document
    # Buscar documento que:
    # 1. Foi criado pelo professor atual OU
    # 2. Pertence a uma disciplina do professor OU
    # 3. Foi compartilhado com a escola (criado por direction/admin da mesma escola)
    @document = Document.left_joins(:subject, :user)
                       .where(
                         'documents.user_id = ? OR
                          (subjects.user_id = ? AND documents.subject_id IS NOT NULL) OR
                          (documents.school_id = ? AND users.user_type IN (?))',
                         current_user.id,
                         current_user.id,
                         current_user.school_id,
                         [ "direction", "admin" ]
                       )
                       .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to teachers_documents_path, alert: "Documento não encontrado ou você não tem permissão para acessá-lo."
  end

  def available_students
    # Buscar turmas do professor através de suas disciplinas
    classroom_ids = current_user.subjects.pluck(:classroom_id).compact.uniq
    
    # Se não há turmas com disciplinas, buscar todos os alunos da escola do professor
    if classroom_ids.empty?
      # Buscar alunos da mesma escola
      User.where(school: current_user.school, user_type: "student")
          .order(:first_name, :last_name)
    else
      # Buscar alunos das turmas onde o professor leciona
      User.where(classroom_id: classroom_ids, user_type: "student")
          .order(:first_name, :last_name)
    end
  end

  def available_classrooms
    current_user.teacher_classrooms.distinct
  end

  def grouped_subjects_for_select
    # Agrupar disciplinas por nome e mostrar apenas uma vez cada disciplina
    subject_groups = current_user.teacher_subjects
                                .includes(:classroom)
                                .group_by(&:name)

    subject_options = []

    subject_groups.each do |subject_name, subjects|
      # Pegar o primeiro subject do grupo para usar como representante
      representative_subject = subjects.first
      subject_options << [ subject_name, representative_subject.id ]
    end

    subject_options.sort_by(&:first)
  end

  def document_params
    params.require(:document).permit(:title, :description, :subject_id, :user_id, :attachment, :document_type, :sharing_type, :classroom_id, :target_student_id)
  end
end
