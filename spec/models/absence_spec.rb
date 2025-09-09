# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence, type: :model do
  describe "associations" do
    it { should belong_to(:student).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:subject) }
  end

  describe "validations" do
    it { should validate_presence_of(:date) }
  end

  describe "scopes" do
    let!(:justified_absence) { create(:absence, :justified) }
    let!(:unjustified_absence) { create(:absence, :unjustified) }
    let!(:old_absence) { create(:absence, :past_date) }
    let!(:recent_absence) { create(:absence) }

    describe ".justified" do
      it "returns only justified absences" do
        expect(Absence.justified).to include(justified_absence)
        expect(Absence.justified).not_to include(unjustified_absence)
      end
    end

    describe ".unjustified" do
      it "returns only unjustified absences" do
        expect(Absence.unjustified).to include(unjustified_absence)
        expect(Absence.unjustified).not_to include(justified_absence)
      end
    end

    describe ".recent" do
      it "orders absences by date desc" do
        expect(Absence.recent.first.date).to be >= Absence.recent.last.date
      end
    end
  end

  describe "custom validations" do
    describe "#student_must_be_student" do
      it "validates that user is a student" do
        teacher = create(:user, :teacher)
        absence = build(:absence, student: teacher)

        expect(absence).not_to be_valid
        expect(absence.errors[:student]).to include("deve ser um aluno")
      end

      it "allows valid student" do
        student = create(:user, :student)
        absence = build(:absence, student: student)

        expect(absence).to be_valid
      end
    end
  end
end
