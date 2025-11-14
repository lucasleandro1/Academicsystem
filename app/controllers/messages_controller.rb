class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [ :show, :destroy ]

  def index
    # Aplicar filtros
    sent_messages = current_user.sent_messages
    received_messages = current_user.received_messages

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
    @message = Message.new
    @recipient_service = MessageRecipientService.new(current_user)
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    # Determinar a escola da mensagem
    if current_user.school
      @message.school = current_user.school
    elsif params[:message][:school_id].present?
      @message.school_id = params[:message][:school_id]
    else
      # Para admin sem escola específica, usar a escola do destinatário
      recipient = User.find_by(id: params[:message][:recipient_id])
      @message.school = recipient&.school if recipient
    end

    if @message.save
      redirect_to messages_path, notice: "Mensagem enviada com sucesso."
    else
      Rails.logger.error "Message creation failed for user #{current_user.id}: #{@message.errors.full_messages.join(', ')}"
      Rails.logger.error "Message attributes: #{@message.attributes.inspect}"
      @recipient_service = MessageRecipientService.new(current_user)
      flash.now[:alert] = "Erro ao enviar mensagem: #{@message.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def destroy
    @message.destroy
    redirect_to messages_path, notice: "Mensagem excluída com sucesso."
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

  def available_recipients
    service = MessageRecipientService.new(current_user)
    service.available_recipients_list
  end
end
