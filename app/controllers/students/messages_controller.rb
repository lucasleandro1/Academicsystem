class Students::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  before_action :set_message, only: [ :show ]

  def index
    @sent_messages = current_user.sent_messages
                                .where(school: current_user.school)
                                .order(created_at: :desc)
                                .limit(20)

    @received_messages = current_user.received_messages
                                    .where(school: current_user.school)
                                    .order(created_at: :desc)
                                    .limit(20)
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
