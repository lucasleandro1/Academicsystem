# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe "associations" do
    it { should belong_to(:classroom).optional }
    it { should belong_to(:school) }
    it { should have_many(:grades).dependent(:destroy) }
    it { should have_many(:absences).dependent(:destroy) }
    it { should have_many(:class_schedules).dependent(:destroy) }
    it { should have_many(:documents).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:subject) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:workload) }
    it { should validate_uniqueness_of(:name).scoped_to([ :school_id, :classroom_id ]) }
    it { should validate_numericality_of(:workload).is_greater_than(0) }
  end

  describe "methods" do
    describe "#students" do
      it "returns students from the classroom" do
        classroom = create(:classroom)
        subject = create(:subject, classroom: classroom)
        student = create(:user, :student, classroom: classroom)

        expect(subject.students).to include(student)
      end
    end

    describe "#average_grade_by_bimester" do
      it "calculates average grade for a bimester" do
        subject = create(:subject)
        student = create(:user, :student)

        create(:grade, subject: subject, student: student, bimester: 1, value: 8.0)
        create(:grade, subject: subject, student: student, bimester: 1, value: 9.0, grade_type: 'trabalho')
        create(:grade, subject: subject, student: student, bimester: 2, value: 7.0)

        expect(subject.average_grade_by_bimester(1)).to eq(8.5)
        expect(subject.average_grade_by_bimester(2)).to eq(7.0)
        expect(subject.average_grade_by_bimester(3)).to be_nil
      end
    end
  end
end
