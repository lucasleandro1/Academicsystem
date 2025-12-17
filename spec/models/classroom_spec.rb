# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classroom, type: :model do
  describe "associations" do
    it { should belong_to(:school) }
    it { should have_many(:students).class_name('User').with_foreign_key('classroom_id') }
    it { should have_many(:subjects).dependent(:destroy) }
    it { should have_many(:class_schedules).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:classroom) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:academic_year) }
    it { should validate_presence_of(:shift) }
    it { should validate_presence_of(:level) }
    it { should validate_uniqueness_of(:name).scoped_to(:school_id) }
  end

  describe "enums" do
    it { should define_enum_for(:shift).with_values(morning: "morning", afternoon: "afternoon", evening: "evening").backed_by_column_of_type(:string) }
    it { should define_enum_for(:level).with_values(
      elementary_1: "elementary_1",
      elementary_2: "elementary_2",
      high_school: "high_school"
    ).backed_by_column_of_type(:string) }
  end

  describe "methods" do
    describe "#display_name" do
      it "returns formatted display name" do
        classroom = build(:classroom, name: "1ºA", academic_year: 2024, shift: "morning")
        expect(classroom.display_name).to eq("1ºA - 2024 (Morning)")
      end
    end

    describe "#student_count" do
      it "returns the number of students" do
        classroom = create(:classroom)
        create_list(:user, 3, :student, classroom: classroom)

        expect(classroom.student_count).to eq(3)
      end
    end
  end
end
