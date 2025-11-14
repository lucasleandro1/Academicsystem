class Students::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  before_action :set_message, only: [ :show ]

  def index
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

    @sent_messages = sent_messages.order(created_at: :desc).limit(50)
    @received_messages = received_messages.order(created_at: :desc).limit(50)
    @unread_count = current_user.received_messages.unread.count
  end

  def show
    @message.mark_as_read! if @message.recipient == current_user && !@message.read?
  end

  def new
    @message = current_user.sent_messages.build
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    @message.school = current_user.school

    if @message.save
      redirect_to students_messages_path, notice: "Mensagem enviada com sucesso."
    else
      @recipient_service = MessageRecipientService.new(current_user)
      render :new
    end
  end

  private

  def set_message
    @message = current_user.received_messages
                          .or(current_user.sent_messages)
                          .find(params[:id])
  end

  def message_params
    params.require(:message).permit(:recipient_id, :subject, :body)
  end

  def ensure_student!
    redirect_to root_path unless current_user.student?
  end
end
