# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should belong_to(:school).optional }
    it { should belong_to(:classroom).optional }

    # Associações como estudante
    it { should have_many(:student_grades).class_name('Grade').with_foreign_key('user_id').dependent(:destroy) }
    it { should have_many(:student_absences).class_name('Absence').with_foreign_key('user_id').dependent(:destroy) }
    it { should have_many(:student_documents).class_name('Document').with_foreign_key('user_id').dependent(:destroy) }

    # Associações como professor
    it { should have_many(:teacher_subjects).class_name('Subject').with_foreign_key('user_id').dependent(:destroy) }
    it { should have_many(:teacher_documents).class_name('Document').with_foreign_key('user_id').dependent(:destroy) }

    # Mensagens
    it { should have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id').dependent(:destroy) }
    it { should have_many(:received_messages).class_name('Message').with_foreign_key('recipient_id').dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    # Teacher validations removed - attributes don't exist

    context "when user is a student" do
      subject { build(:user, :student) }
      it { should validate_presence_of(:birth_date) }
      it { should validate_presence_of(:guardian_name) }
    end
  end

  describe "enums" do
    it { should define_enum_for(:user_type).with_values(student: "student", teacher: "teacher", direction: "direction", admin: "admin").backed_by_column_of_type(:string) }
  end

  describe "methods" do
    describe "#full_name" do
      it "returns the combination of first and last name" do
        user = build(:user, first_name: "João", last_name: "Silva")
        expect(user.full_name).to eq("João Silva")
      end

      it "returns email username when names are not present" do
        user = build(:user, email: "joao.silva@email.com", first_name: nil, last_name: nil)
        expect(user.full_name).to eq("Joao.silva")
      end
    end

    describe "#age" do
      it "calculates age based on birth_date" do
        user = build(:user, birth_date: 20.years.ago.to_date)
        expect(user.age).to eq(20)
      end

      it "returns nil when birth_date is not present" do
        user = build(:user, birth_date: nil)
        expect(user.age).to be_nil
      end
    end

    describe "#teacher_classrooms" do
      it "returns classrooms for teacher through subjects and schedules" do
        school = create(:school)
        teacher = create(:user, :teacher, school: school)
        classroom = create(:classroom, school: school)
        subject = create(:subject, user: teacher, classroom: classroom, school: school)
        schedule = create(:class_schedule, subject: subject, classroom: classroom, school: school)

        # Debug the associations
        expect(teacher.teacher_subjects).to include(subject)
        expect(subject.class_schedules).to include(schedule)
        expect(teacher.teacher_classrooms.to_a).to include(classroom)
      end

      it "returns empty relation for non-teacher users" do
        student = create(:user, :student)
        expect(student.teacher_classrooms).to eq(Classroom.none)
      end
    end
  end

  describe "user types" do
    it "identifies student type correctly" do
      user = build(:user, :student)
      expect(user.student?).to be true
      expect(user.teacher?).to be false
      expect(user.direction?).to be false
      expect(user.admin?).to be false
    end

    it "identifies teacher type correctly" do
      user = build(:user, :teacher)
      expect(user.teacher?).to be true
      expect(user.student?).to be false
      expect(user.direction?).to be false
      expect(user.admin?).to be false
    end

    it "identifies direction type correctly" do
      user = build(:user, :direction)
      expect(user.direction?).to be true
      expect(user.student?).to be false
      expect(user.teacher?).to be false
      expect(user.admin?).to be false
    end

    it "identifies admin type correctly" do
      user = build(:user, :admin)
      expect(user.admin?).to be true
      expect(user.student?).to be false
      expect(user.teacher?).to be false
      expect(user.direction?).to be false
    end
  end
end
