# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:school) { create(:school) }
  let(:classroom) { create(:classroom, school: school) }

  # Criar usuários de diferentes tipos
  let(:admin) { create(:user, :admin, school: school) }
  let(:director) { create(:user, :direction, school: school) }
  let(:teacher) { create(:user, :teacher, school: school) }
  let(:student) { create(:user, :student, school: school, classroom: classroom) }

  # Usuários de outra escola
  let(:other_school) { create(:school) }
  let(:other_director) { create(:user, :direction, school: other_school) }
  let(:other_teacher) { create(:user, :teacher, school: other_school) }
  let(:other_student) { create(:user, :student, school: other_school) }

  describe "GET #new" do
    context "when user is admin" do
      before { sign_in admin }

      it "shows all users except himself as available recipients" do
        get :new
        expect(assigns(:recipients)).to include(director, teacher, student)
        expect(assigns(:recipients)).not_to include(admin)
      end
    end

    context "when user is director" do
      before { sign_in director }

      it "shows only users from same school as available recipients" do
        get :new
        expect(assigns(:recipients)).to include(teacher, student)
        expect(assigns(:recipients)).not_to include(director, other_director, other_teacher, other_student)
      end
    end

    context "when user is teacher" do
      before do
        # Criar disciplina para o professor com os alunos
        create(:subject, user: teacher, classroom: classroom)
        sign_in teacher
      end

      it "shows students from their classes and directors as available recipients" do
        get :new
        recipients = assigns(:recipients)
        expect(recipients).to include(student, director)
        expect(recipients).not_to include(teacher, other_teacher, other_student, other_director)
      end
    end

    context "when user is student" do
      before do
        # Criar disciplina para que o aluno tenha acesso ao professor
        create(:subject, user: teacher, classroom: classroom)
        sign_in student
      end

      it "shows teachers from their subjects and directors as available recipients" do
        get :new
        recipients = assigns(:recipients)
        expect(recipients).to include(teacher, director)
        expect(recipients).not_to include(student, other_teacher, other_student, other_director)
      end
    end
  end

  describe "POST #create" do
    let(:message_params) do
      {
        message: {
          recipient_id: recipient.id,
          subject: "Assunto de teste",
          body: "Corpo da mensagem de teste"
        }
      }
    end

    shared_examples "creates message successfully" do
      it "creates the message" do
        expect {
          post :create, params: message_params
        }.to change(Message, :count).by(1)

        message = Message.last
        expect(message.sender).to eq(sender)
        expect(message.recipient).to eq(recipient)
        expect(message.school).to eq(sender.school)
        expect(response).to redirect_to(messages_path)
      end
    end

    shared_examples "blocks message creation" do
      it "does not create the message" do
        expect {
          post :create, params: message_params
        }.not_to change(Message, :count)
      end
    end

    context "when admin sends message" do
      let(:sender) { admin }
      before { sign_in sender }

      context "to any user" do
        let(:recipient) { teacher }
        include_examples "creates message successfully"
      end

      context "to user from different school" do
        let(:recipient) { other_teacher }
        include_examples "creates message successfully"
      end
    end

    context "when director sends message" do
      let(:sender) { director }
      before { sign_in sender }

      context "to user from same school" do
        let(:recipient) { teacher }
        include_examples "creates message successfully"
      end

      context "to student from same school" do
        let(:recipient) { student }
        include_examples "creates message successfully"
      end
    end

    context "when teacher sends message" do
      let(:sender) { teacher }
      before do
        # Criar disciplina para o professor com os alunos
        create(:subject, user: teacher, classroom: classroom)
        sign_in sender
      end

      context "to student from their class" do
        let(:recipient) { student }
        include_examples "creates message successfully"
      end

      context "to director from same school" do
        let(:recipient) { director }
        include_examples "creates message successfully"
      end

      context "to another teacher" do
        let(:other_teacher_same_school) { create(:user, :teacher, school: school) }
        let(:recipient) { other_teacher_same_school }
        include_examples "creates message successfully"
      end
    end

    context "when student sends message" do
      let(:sender) { student }
      before do
        # Criar disciplina para que o aluno tenha acesso ao professor
        create(:subject, user: teacher, classroom: classroom)
        sign_in sender
      end

      context "to teacher from their subjects" do
        let(:recipient) { teacher }
        include_examples "creates message successfully"
      end

      context "to director from same school" do
        let(:recipient) { director }
        include_examples "creates message successfully"
      end
    end
  end

  describe "authorization rules" do
    let(:message_params) do
      {
        message: {
          recipient_id: unauthorized_recipient.id,
          subject: "Assunto não autorizado",
          body: "Tentativa de envio não autorizado"
        }
      }
    end

    context "teacher trying to send to student from different class" do
      let(:other_classroom) { create(:classroom, school: school) }
      let(:other_student) { create(:user, :student, school: school, classroom: other_classroom) }

      before do
        sign_in teacher
        # Não criar subject para este classroom
      end

      let(:unauthorized_recipient) { other_student }

      it "should not allow sending message" do
        post :create, params: message_params
        expect(response).to render_template(:new)
        expect(assigns(:message).errors).not_to be_empty
      end
    end

    context "student trying to send to another student" do
      let(:other_student) { create(:user, :student, school: school, classroom: classroom) }

      before { sign_in student }
      let(:unauthorized_recipient) { other_student }

      it "should not allow sending message" do
        post :create, params: message_params
        expect(response).to render_template(:new)
        expect(assigns(:message).errors).not_to be_empty
      end
    end

    context "director trying to send to user from different school" do
      before { sign_in director }
      let(:unauthorized_recipient) { other_teacher }

      it "should not allow sending message" do
        post :create, params: message_params
        expect(response).to render_template(:new)
        expect(assigns(:message).errors).not_to be_empty
      end
    end
  end

  describe "GET #index" do
    let(:user) { teacher }
    let!(:sent_message) { create(:message, sender: user, recipient: student, school: school) }
    let!(:received_message) { create(:message, sender: admin, recipient: user, school: school) }
    let!(:unread_message) { create(:message, :unread, sender: admin, recipient: user, school: school) }

    before do
      # Criar disciplina para o teacher poder enviar para o student
      create(:subject, user: teacher, classroom: classroom)
      sign_in user
    end

    it "loads sent and received messages" do
      get :index
      expect(assigns(:sent_messages)).to include(sent_message)
      expect(assigns(:received_messages)).to include(received_message, unread_message)
      expect(assigns(:unread_count)).to eq(1)
    end
  end

  describe "GET #show" do
    let(:user) { student }
    let!(:message) { create(:message, :unread, sender: admin, recipient: user, school: school) }

    before { sign_in user }

    it "marks message as read when recipient views it" do
      expect {
        get :show, params: { id: message.id }
      }.to change { message.reload.read? }.from(false).to(true)
    end

    it "does not mark message as read when sender views it" do
      sign_in message.sender
      expect {
        get :show, params: { id: message.id }
      }.not_to change { message.reload.read? }
    end
  end

  describe "DELETE #destroy" do
    let(:user) { teacher }
    let!(:sent_message) { create(:message, sender: user, recipient: student, school: school) }
    let!(:received_message) { create(:message, sender: admin, recipient: user, school: school) }

    before do
      # Criar disciplina para o teacher poder enviar para o student
      create(:subject, user: teacher, classroom: classroom)
      sign_in user
    end

    it "allows user to delete their sent messages" do
      expect {
        delete :destroy, params: { id: sent_message.id }
      }.to change(Message, :count).by(-1)
      expect(response).to redirect_to(messages_path)
    end

    it "allows user to delete their received messages" do
      expect {
        delete :destroy, params: { id: received_message.id }
      }.to change(Message, :count).by(-1)
      expect(response).to redirect_to(messages_path)
    end

    it "does not allow user to delete messages they are not involved in" do
      other_message = create(:message, sender: admin, recipient: director, school: school)
      expect {
        delete :destroy, params: { id: other_message.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
