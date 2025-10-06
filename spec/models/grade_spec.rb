# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grade, type: :model do
  describe "associations" do
    it { should belong_to(:student).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:subject) }
  end

  describe "validations" do
    subject { build(:grade) }

    it { should validate_presence_of(:value) }
    it { should validate_presence_of(:bimester) }
    it { should validate_presence_of(:grade_type) }

    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10) }
    it { should validate_inclusion_of(:bimester).in_array([ 1, 2, 3, 4 ]) }
    it { should validate_uniqueness_of(:user_id).scoped_to([ :subject_id, :bimester, :grade_type ]) }
  end

  describe "enums" do
    it { should define_enum_for(:grade_type).with_values(
      prova: "prova",
      trabalho: "trabalho",
      atividade: "atividade",
      participacao: "participacao",
      projeto: "projeto"
    ).backed_by_column_of_type(:string) }
  end

  describe "scopes" do
    let!(:grade1) { create(:grade, bimester: 1, subject: create(:subject)) }
    let!(:grade2) { create(:grade, bimester: 2, subject: create(:subject)) }
    let!(:grade3) { create(:grade, bimester: 1, subject: grade1.subject) }

    describe ".by_bimester" do
      it "filters grades by bimester" do
        expect(Grade.by_bimester(1)).to include(grade1, grade3)
        expect(Grade.by_bimester(1)).not_to include(grade2)
      end
    end

    describe ".by_subject" do
      it "filters grades by subject" do
        expect(Grade.by_subject(grade1.subject.id)).to include(grade1, grade3)
        expect(Grade.by_subject(grade1.subject.id)).not_to include(grade2)
      end
    end

    describe ".recent" do
      it "orders grades by creation date desc" do
        expect(Grade.recent.first.created_at).to be >= Grade.recent.last.created_at
      end
    end
  end

  describe "custom validations" do
    describe "#student_must_be_student" do
      it "validates that user is a student" do
        teacher = create(:user, :teacher)
        grade = build(:grade, student: teacher)

        expect(grade).not_to be_valid
        expect(grade.errors[:student]).to include("deve ser um aluno")
      end

      it "allows valid student" do
        student = create(:user, :student)
        grade = build(:grade, student: student)

        expect(grade).to be_valid
      end
    end
  end
end
