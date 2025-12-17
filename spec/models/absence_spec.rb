# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence, type: :model do
  describe "associations" do
    it { should belong_to(:student).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:subject) }
  end

  describe "validations" do
    it { should validate_presence_of(:date) }

    describe "justification validation" do
      let(:school) { create(:school) }
      let(:classroom) { create(:classroom, school: school) }
      let(:teacher) { create(:user, :teacher, school: school) }
      let(:subject) { create(:subject, classroom: classroom, school: school, user: teacher) }
      let(:student) { create(:user, :student, classroom: classroom, school: school) }

      it "requires justification when justified is true" do
        absence = build(:absence, subject: subject, student: student, justified: true, justification: nil)

        expect(absence).not_to be_valid
        expect(absence.errors[:justification]).to be_present
      end

      it "allows justified absence with justification" do
        absence = build(:absence, subject: subject, student: student, justified: true, justification: "Consulta médica")

        absence.valid?
        expect(absence.errors[:justification]).to be_empty
      end

      it "does not require justification when justified is false" do
        absence = build(:absence, subject: subject, student: student, justified: false, justification: nil)

        absence.valid?
        expect(absence.errors[:justification]).to be_empty
      end
    end
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

  describe "#class_schedule" do
    let!(:school) { create(:school) }
    let!(:classroom) { create(:classroom, school: school) }
    let!(:teacher) { create(:user, :teacher, school: school) }
    let!(:subject) { create(:subject, classroom: classroom, school: school, user: teacher) }
    let!(:monday_schedule) { create(:class_schedule, subject: subject, weekday: 1, classroom: classroom, school: school) } # Monday
    let!(:tuesday_schedule) { create(:class_schedule, subject: subject, weekday: 2, classroom: classroom, school: school) } # Tuesday

    context "when absence date matches a class schedule weekday" do
      it "returns the matching class schedule for Monday" do
        # Use a date that is definitely a Monday
        monday_date = Date.new(2024, 10, 28) # This is a Monday
        absence = create(:absence, subject: subject, date: monday_date)

        expect(absence.class_schedule).to eq(monday_schedule)
      end

      it "returns the matching class schedule for Tuesday" do
        # Use a date that is definitely a Tuesday  
        tuesday_date = Date.new(2024, 10, 29) # This is a Tuesday
        absence = create(:absence, subject: subject, date: tuesday_date)

        expect(absence.class_schedule).to eq(tuesday_schedule)
      end
    end

    context "when no class schedule exists for the weekday" do
      it "returns nil" do
        # Use a date that is definitely a Sunday
        sunday_date = Date.new(2024, 10, 27) # This is a Sunday
        absence = create(:absence, subject: subject, date: sunday_date)

        expect(absence.class_schedule).to be_nil
      end
    end

    context "when absence has no date" do
      it "returns nil" do
        absence = build(:absence, subject: subject, date: nil)

        expect(absence.class_schedule).to be_nil
      end
    end

    context "when absence has no subject" do
      it "returns nil" do
        absence = build(:absence, subject: nil, date: Date.current)

        expect(absence.class_schedule).to be_nil
      end
    end
  end
end
