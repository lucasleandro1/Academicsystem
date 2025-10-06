class Admin::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    @sent_messages = current_user.sent_messages.recent.includes(:recipient, :school)
    @received_messages = current_user.received_messages.recent.includes(:sender, :school)
    @unread_count = current_user.received_messages.unread.count
  end

  def new
    @message = Message.new
    @broadcast_type = params[:broadcast_type]
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    if params[:broadcast_type].present?
      handle_broadcast_message
    else
      @message.school_id = params[:message][:school_id] if params[:message][:school_id].present?
      if @message.save
        redirect_to admin_messages_path, notice: "Mensagem enviada com sucesso."
      else
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
