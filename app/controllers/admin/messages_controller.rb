class Admin::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

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

    @sent_messages = sent_messages.includes(:recipient, :school).order(created_at: :desc).limit(50)
    @received_messages = received_messages.includes(:sender, :school).order(created_at: :desc).limit(50)
    @unread_count = current_user.received_messages.unread.count
  end

  def new
    @message = Message.new
    @broadcast_type = params[:broadcast_type]
    @recipient_service = MessageRecipientService.new(current_user)
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    if params[:broadcast_type].present?
      handle_broadcast_message
    else
      # Para admin, definir school com base no recipient
      if @message.recipient_id.present?
        recipient = User.find(@message.recipient_id)
        @message.school = recipient.school if recipient.school.present?
      end

      # Fallback para school_id nos parâmetros
      @message.school_id = params[:message][:school_id] if params[:message][:school_id].present?

      if @message.save
        redirect_to admin_messages_path, notice: "Mensagem enviada com sucesso."
      else
        @recipient_service = MessageRecipientService.new(current_user)
        render :new
      end
    end
  end

  def broadcast_to_all_schools
    render :new, locals: { broadcast_type: "all_schools" }
  end

  def broadcast_to_all_directors
    render :new, locals: { broadcast_type: "all_directors" }
  end

  def broadcast_to_school
    @school = School.find(params[:school_id])
    render :new, locals: { broadcast_type: "school", school: @school }
  end

  private

  def message_params
    params.require(:message).permit(:subject, :body, :school_id, :recipient_id)
  end

  def handle_broadcast_message
    success_count = 0
    error_count = 0

    recipients = get_broadcast_recipients

    recipients.each do |recipient|
      message = current_user.sent_messages.build(
        subject: params[:message][:subject],
        body: params[:message][:body],
        recipient: recipient,
        school: recipient.school || School.first
      )

      if message.save
        success_count += 1
      else
        error_count += 1
      end
    end

    if error_count == 0
      redirect_to admin_messages_path,
                  notice: "Comunicado enviado com sucesso para #{success_count} destinatários."
    else
      redirect_to admin_messages_path,
                  alert: "#{success_count} mensagens enviadas, #{error_count} falharam."
    end
  end

  def get_broadcast_recipients
    case params[:broadcast_type]
    when "all_schools"
      User.directions
    when "all_directors"
      User.directions
    when "school"
      school = School.find(params[:school_id])
      school.users.where.not(id: current_user.id)
    when "all_teachers"
      User.teachers
    when "all_students"
      User.students
    else
      User.none
    end
  end
end
