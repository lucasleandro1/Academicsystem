class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [ :show, :destroy ]

  def index
    @sent_messages = current_user.sent_messages.recent.includes(:recipient)
    @received_messages = current_user.received_messages.recent.includes(:sender)
    @unread_count = current_user.received_messages.unread.count
  end

  def show
    @message.mark_as_read! if @message.recipient == current_user
  end

  def new
    @message = Message.new
    @recipients = available_recipients
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    @message.school = current_user.school

    if @message.save
      redirect_to messages_path, notice: "Mensagem enviada com sucesso."
    else
      @recipients = available_recipients
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
    case current_user.user_type
    when "admin"
      User.where.not(id: current_user.id)
    when "direction"
      current_user.school.users.where.not(id: current_user.id)
    when "teacher"
      # Professores podem enviar para direção e alunos de suas turmas
      classroom_ids = current_user.teacher_subjects.pluck(:classroom_id)
      student_ids = User.where(classroom_id: classroom_ids, user_type: "student").pluck(:id)
      direction_ids = current_user.school.directions.pluck(:id)
      User.where(id: student_ids + direction_ids)
    when "student"
      # Alunos podem enviar para professores de suas matérias e direção
      return User.none unless current_user.classroom

      teacher_ids = current_user.classroom.subjects.pluck(:user_id)
      direction_ids = current_user.school.directions.pluck(:id)
      User.where(id: teacher_ids + direction_ids)
    else
      User.none
    end
  end
end
