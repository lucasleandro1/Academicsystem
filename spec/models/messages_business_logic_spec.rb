# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Messages Business Logic", type: :model do
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

  describe "available_recipients logic" do
    it "admin can send messages to anyone" do
      # Simular o método available_recipients do controller para admin
      recipients = case admin.user_type
      when "admin"
        User.where.not(id: admin.id)
      end

      expect(recipients).to include(director, teacher, student, other_director, other_teacher, other_student)
      expect(recipients).not_to include(admin)
    end

    it "director can send messages only to users from same school" do
      recipients = case director.user_type
      when "direction"
        director.school.users.where.not(id: director.id)
      end

      expect(recipients).to include(teacher, student)
      expect(recipients).not_to include(director, other_director, other_teacher, other_student)
    end

    it "teacher can send messages to students from their classes, directors, and other teachers" do
      # Criar disciplina para o professor com os alunos
      create(:subject, user: teacher, classroom: classroom, school: school)
      
      # Simular método do controller para teacher (igual ao controller)
      classroom_ids = teacher.teacher_subjects.pluck(:classroom_id)
      student_ids = User.where(classroom_id: classroom_ids, user_type: "student").pluck(:id)
      direction_ids = teacher.school.directions.pluck(:id)
      teacher_ids = teacher.school.teachers.where.not(id: teacher.id).pluck(:id)
      recipients = User.where(id: student_ids + direction_ids + teacher_ids)

      expect(recipients).to include(student, director)
      expect(recipients).not_to include(teacher, other_teacher, other_student, other_director)
    end

    it "student can send messages only to teachers from their subjects and directors" do
      # Criar disciplina para que o aluno tenha acesso ao professor
      create(:subject, user: teacher, classroom: classroom, school: school)
      
      # Simular método do controller para student
      teacher_ids = student.classroom.subjects.pluck(:user_id)
      direction_ids = student.school.directions.pluck(:id)
      recipients = User.where(id: teacher_ids + direction_ids)

      expect(recipients).to include(teacher, director)
      expect(recipients).not_to include(student, other_teacher, other_student, other_director)
    end
  end

  describe "Message model validations" do
    context "when admin sends message" do
      it "allows message to anyone" do
        message = build(:message, sender: admin, recipient: teacher, school: admin.school)
        expect(message).to be_valid
      end

      it "allows message to user from different school" do
        message = build(:message, sender: admin, recipient: other_teacher, school: admin.school)
        expect(message).to be_valid
      end
    end

    context "when director sends message" do
      it "allows message to user from same school" do
        message = build(:message, sender: director, recipient: teacher, school: director.school)
        expect(message).to be_valid
      end

      it "allows message to student from same school" do
        message = build(:message, sender: director, recipient: student, school: director.school)
        expect(message).to be_valid
      end

      it "blocks message to user from different school" do
        message = build(:message, sender: director, recipient: other_teacher, school: director.school)
        expect(message).not_to be_valid
        expect(message.errors[:recipient_id]).to include("não é um destinatário autorizado para seu tipo de usuário")
      end
    end

    context "when teacher sends message" do
      before do
        # Criar disciplina para o professor com os alunos
        create(:subject, user: teacher, classroom: classroom, school: school)
      end

      it "allows message to student from their class" do
        message = build(:message, sender: teacher, recipient: student, school: teacher.school)
        expect(message).to be_valid
      end

      it "allows message to director from same school" do
        message = build(:message, sender: teacher, recipient: director, school: teacher.school)
        expect(message).to be_valid
      end

      it "allows message to another teacher from same school" do
        other_teacher_same_school = create(:user, :teacher, school: school)
        message = build(:message, sender: teacher, recipient: other_teacher_same_school, school: teacher.school)
        expect(message).to be_valid
      end

      it "blocks message to student from different class" do
        other_classroom = create(:classroom, school: school)
        other_student = create(:user, :student, school: school, classroom: other_classroom)
        message = build(:message, sender: teacher, recipient: other_student, school: teacher.school)
        
        expect(message).not_to be_valid
        expect(message.errors[:recipient_id]).to include("não é um destinatário autorizado para seu tipo de usuário")
      end
    end

    context "when student sends message" do
      before do
        # Criar disciplina para que o aluno tenha acesso ao professor
        create(:subject, user: teacher, classroom: classroom, school: school)
      end

      it "allows message to teacher from their subjects" do
        message = build(:message, sender: student, recipient: teacher, school: student.school)
        expect(message).to be_valid
      end

      it "allows message to director from same school" do
        message = build(:message, sender: student, recipient: director, school: student.school)
        expect(message).to be_valid
      end

      it "blocks message to another student" do
        other_student = create(:user, :student, school: school, classroom: classroom)
        message = build(:message, sender: student, recipient: other_student, school: student.school)
        
        expect(message).not_to be_valid
        expect(message.errors[:recipient_id]).to include("não é um destinatário autorizado para seu tipo de usuário")
      end

      it "blocks message to teacher from different school" do
        message = build(:message, sender: student, recipient: other_teacher, school: student.school)
        
        expect(message).not_to be_valid
        expect(message.errors[:recipient_id]).to include("não é um destinatário autorizado para seu tipo de usuário")
      end
    end
  end

  describe "Message creation with proper recipients" do
    it "successfully creates valid messages using factories" do
      # Admin para teacher
      message1 = create(:message, sender: admin, recipient: teacher, school: admin.school)
      expect(message1).to be_persisted

      # Teacher para student (com disciplina)
      create(:subject, user: teacher, classroom: classroom, school: school)
      message2 = create(:message, sender: teacher, recipient: student, school: teacher.school)
      expect(message2).to be_persisted

      # Student para teacher (com disciplina)
      message3 = create(:message, sender: student, recipient: teacher, school: student.school)
      expect(message3).to be_persisted

      # Director para student
      message4 = create(:message, sender: director, recipient: student, school: director.school)
      expect(message4).to be_persisted
    end
  end
end