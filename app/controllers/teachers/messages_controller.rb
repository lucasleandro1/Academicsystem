class Teachers::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_teacher!
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
  end

  def show
    @message.mark_as_read! unless @message.read?
  end

  def new
    @message = current_user.sent_messages.build
    @students = available_students
    @classrooms = available_classrooms
    @directions = available_directions
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    @message.school = current_user.school

    if @message.save
      redirect_to teachers_messages_path, notice: "Mensagem enviada com sucesso."
    else
      @students = available_students
      @classrooms = available_classrooms
      @directions = available_directions
      render :new
    end
  end

  def send_to_student
    student = User.find(params[:student_id])
    message = create_message_to_user(student, params[:content], params[:subject])

    if message.persisted?
      render json: { status: "success", message: "Mensagem enviada para o aluno." }
    else
      render json: { status: "error", message: "Erro ao enviar mensagem." }
    end
  end

  def send_to_classroom
    classroom = Classroom.find(params[:classroom_id])
    students = classroom.students

    messages_sent = 0
    students.each do |student|
      message = create_message_to_user(student, params[:content], params[:subject])
      messages_sent += 1 if message.persisted?
    end

    render json: {
      status: "success",
      message: "Mensagem enviada para #{messages_sent} aluno(s) da turma."
    }
  end

  def send_to_direction
    directions = current_user.school.users.where(profile: "direction")

    messages_sent = 0
    directions.each do |direction|
      message = create_message_to_user(direction, params[:content], params[:subject])
      messages_sent += 1 if message.persisted?
    end

    render json: {
      status: "success",
      message: "Mensagem enviada para #{messages_sent} membro(s) da direção."
    }
  end

  private

  def set_message
    @message = current_user.received_messages
                          .or(current_user.sent_messages)
                          .find(params[:id])
  end

  def available_students
    classroom_ids = current_user.teacher_subjects.pluck(:classroom_id).uniq
    User.where(classroom_id: classroom_ids, user_type: "student")
        .distinct
  end

  def available_classrooms
    classroom_ids = current_user.teacher_subjects.pluck(:classroom_id).uniq
    Classroom.where(id: classroom_ids)
  end

  def available_directions
    current_user.school.users.where(profile: "direction")
  end

  def create_message_to_user(recipient, content, subject)
    current_user.sent_messages.create(
      recipient: recipient,
      subject: subject,
      content: content,
      school: current_user.school
    )
  end

  def message_params
    params.require(:message).permit(:recipient_id, :subject, :content)
  end
end
