class Direction::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!
  before_action :set_message, only: [ :show ]

  def index
    @school = current_user.school

    # Aplicar filtros
    sent_messages = current_user.sent_messages.where(school: current_user.school)
    received_messages = current_user.received_messages.where(school: current_user.school)

    # Filtro por status
    if params[:status].present?
      case params[:status]
      when "unread"
        sent_messages = sent_messages.where(read: false)
        received_messages = received_messages.unread
      when "read"
        sent_messages = sent_messages.where(read: true)
        received_messages = received_messages.where(read_at: nil..)
      end
    end

    # Filtro por tipo
    if params[:type].present?
      case params[:type]
      when "received"
        sent_messages = sent_messages.none
      when "sent"
        received_messages = received_messages.none
      end
    end

    # Filtro de busca
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      sent_messages = sent_messages.joins(:recipient)
                                  .where("messages.subject ILIKE ? OR messages.body ILIKE ? OR users.full_name ILIKE ?",
                                         search_term, search_term, search_term)
      received_messages = received_messages.joins(:sender)
                                          .where("messages.subject ILIKE ? OR messages.body ILIKE ? OR users.full_name ILIKE ?",
                                                 search_term, search_term, search_term)
    end

    @sent_messages = sent_messages.includes(:recipient).order(created_at: :desc).limit(50)
    @received_messages = received_messages.includes(:sender).order(created_at: :desc).limit(50)
    @unread_count = current_user.received_messages.unread.count
  end

  def show
    @message.mark_as_read! if @message.recipient == current_user
  end

  def new
    @school = current_user.school
    @message = Message.new
    @recipient_service = MessageRecipientService.new(current_user)
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    @message.school = current_user.school

    if @message.save
      redirect_to direction_messages_path, notice: "Mensagem enviada com sucesso."
    else
      @recipient_service = MessageRecipientService.new(current_user)
      render :new
    end
  end

  def broadcast_to_all
    @school = current_user.school
    subject = params[:subject]
    body = params[:body]

    users_to_notify = @school.users.where.not(id: current_user.id)

    users_to_notify.find_each do |user|
      Message.create!(
        sender: current_user,
        recipient: user,
        school: @school,
        subject: subject,
        body: body
      )
    end

    redirect_to direction_messages_path,
                notice: "Comunicado enviado para todos os usuários da escola (#{users_to_notify.count} pessoas)."
  end

  def broadcast_to_teachers
    @school = current_user.school
    subject = params[:subject]
    body = params[:body]

    teachers = @school.teachers

    teachers.find_each do |teacher|
      Message.create!(
        sender: current_user,
        recipient: teacher,
        school: @school,
        subject: subject,
        body: body
      )
    end

    redirect_to direction_messages_path,
                notice: "Comunicado enviado para todos os professores (#{teachers.count} pessoas)."
  end

  def broadcast_to_students
    @school = current_user.school
    subject = params[:subject]
    body = params[:body]

    students = @school.students

    students.find_each do |student|
      Message.create!(
        sender: current_user,
        recipient: student,
        school: @school,
        subject: subject,
        body: body
      )
    end

    redirect_to direction_messages_path,
                notice: "Comunicado enviado para todos os alunos (#{students.count} pessoas)."
  end

  def broadcast_to_classroom
    @school = current_user.school
    classroom_id = params[:classroom_id]
    subject = params[:subject]
    body = params[:body]

    classroom = @school.classrooms.find(classroom_id)
    users_to_notify = classroom.students # Usando a associação correta

    users_to_notify.find_each do |user|
      Message.create!(
        sender: current_user,
        recipient: user,
        school: @school,
        subject: subject,
        body: body
      )
    end

    redirect_to direction_messages_path,
                notice: "Comunicado enviado para a turma #{classroom.name} (#{users_to_notify.count} pessoas)."
  end

  private


  def set_message
    @message = Message.where(
      "(sender_id = ? OR recipient_id = ?)",
      current_user.id, current_user.id
    ).find(params[:id])
  end

  def message_params
    params.require(:message).permit(:recipient_id, :subject, :body)
  end
end
