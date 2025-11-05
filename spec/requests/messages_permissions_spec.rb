# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Message Permissions System", type: :request do
  let(:school) { create(:school) }
  let(:other_school) { create(:school) }
  let(:classroom) { create(:classroom, school: school) }
  let(:other_classroom) { create(:classroom, school: school) }

  # Criar usuários de diferentes tipos
  let(:admin) { create(:user, :admin, school: school) }
  let(:director) { create(:user, :direction, school: school) }
  let(:teacher) { create(:user, :teacher, school: school) }
  let(:student) { create(:user, :student, school: school, classroom: classroom) }

  # Usuários de outra escola
  let(:other_director) { create(:user, :direction, school: other_school) }
  let(:other_teacher) { create(:user, :teacher, school: other_school) }
  let(:other_student) { create(:user, :student, school: other_school) }

  # Outros usuários da mesma escola
  let(:another_teacher) { create(:user, :teacher, school: school) }
  let(:student_from_different_class) { create(:user, :student, school: school, classroom: other_classroom) }

  describe "Admin permissions" do
    before { sign_in admin }

    it "can send message to any user" do
      post messages_path, params: {
        message: {
          recipient_id: teacher.id,
          subject: "Mensagem do Admin",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(admin)
      expect(Message.last.recipient).to eq(teacher)
    end

    it "can send message to users from different schools" do
      post messages_path, params: {
        message: {
          recipient_id: other_teacher.id,
          subject: "Mensagem do Admin",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(admin)
      expect(Message.last.recipient).to eq(other_teacher)
    end
  end

  describe "Director permissions" do
    before { sign_in director }

    it "can send message to users from same school" do
      post messages_path, params: {
        message: {
          recipient_id: teacher.id,
          subject: "Mensagem do Diretor",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(director)
      expect(Message.last.recipient).to eq(teacher)
    end

    it "cannot send message to users from different school" do
      expect {
        post messages_path, params: {
          message: {
            recipient_id: other_teacher.id,
            subject: "Mensagem não autorizada",
            body: "Conteúdo da mensagem"
          }
        }
      }.not_to change(Message, :count)
    end
  end

  describe "Teacher permissions" do
    before do
      # Criar disciplina para o professor poder ensinar o aluno
      create(:subject, user: teacher, classroom: classroom)
      sign_in teacher
    end

    it "can send message to students from their classes" do
      post messages_path, params: {
        message: {
          recipient_id: student.id,
          subject: "Mensagem do Professor",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(teacher)
      expect(Message.last.recipient).to eq(student)
    end

    it "can send message to directors" do
      post messages_path, params: {
        message: {
          recipient_id: director.id,
          subject: "Mensagem para Diretor",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(teacher)
      expect(Message.last.recipient).to eq(director)
    end

    it "can send message to other teachers" do
      post messages_path, params: {
        message: {
          recipient_id: another_teacher.id,
          subject: "Mensagem para Colega",
          body: "Conteúdo da mensagem"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(teacher)
      expect(Message.last.recipient).to eq(another_teacher)
    end

    it "cannot send message to students from different classes" do
      expect {
        post messages_path, params: {
          message: {
            recipient_id: student_from_different_class.id,
            subject: "Mensagem não autorizada",
            body: "Conteúdo da mensagem"
          }
        }
      }.not_to change(Message, :count)
    end
  end

  describe "Student permissions" do
    before do
      # Criar disciplina para que o aluno tenha acesso ao professor
      create(:subject, user: teacher, classroom: classroom)
      sign_in student
    end

    it "can send message to teachers from their subjects" do
      post messages_path, params: {
        message: {
          recipient_id: teacher.id,
          subject: "Dúvida sobre a matéria",
          body: "Conteúdo da dúvida"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(student)
      expect(Message.last.recipient).to eq(teacher)
    end

    it "can send message to directors" do
      post messages_path, params: {
        message: {
          recipient_id: director.id,
          subject: "Solicitação",
          body: "Conteúdo da solicitação"
        }
      }

      expect(response).to redirect_to(messages_path)
      expect(Message.last.sender).to eq(student)
      expect(Message.last.recipient).to eq(director)
    end

    it "cannot send message to other students" do
      other_student = create(:user, :student, school: school, classroom: classroom)

      expect {
        post messages_path, params: {
          message: {
            recipient_id: other_student.id,
            subject: "Mensagem não autorizada",
            body: "Conteúdo da mensagem"
          }
        }
      }.not_to change(Message, :count)
    end

    it "cannot send message to teachers from other schools" do
      expect {
        post messages_path, params: {
          message: {
            recipient_id: other_teacher.id,
            subject: "Mensagem não autorizada",
            body: "Conteúdo da mensagem"
          }
        }
      }.not_to change(Message, :count)
    end
  end

  describe "Message reading functionality" do
    let!(:message) { create(:message, sender: admin, recipient: student, school: school) }

    before { sign_in student }

    it "marks message as read when recipient views it" do
      expect(message.read?).to be_false

      get message_path(message)

      expect(message.reload.read?).to be_true
      expect(response).to be_successful
    end
  end

  describe "Message listing" do
    before do
      create(:subject, user: teacher, classroom: classroom)
      # Criar algumas mensagens
      @sent_message = create(:message, sender: teacher, recipient: student, school: school)
      @received_message = create(:message, sender: admin, recipient: teacher, school: school)
      @unread_message = create(:message, :unread, sender: admin, recipient: teacher, school: school)

      sign_in teacher
    end

    it "shows sent and received messages" do
      get messages_path

      expect(response).to be_successful
      expect(assigns(:sent_messages)).to include(@sent_message)
      expect(assigns(:received_messages)).to include(@received_message, @unread_message)
      expect(assigns(:unread_count)).to eq(1)
    end
  end
end
