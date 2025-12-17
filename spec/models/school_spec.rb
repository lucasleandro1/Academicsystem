# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School, type: :model do
  describe "associations" do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:classrooms).dependent(:destroy) }
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:documents).dependent(:destroy) }
    it { should have_many(:subjects).dependent(:destroy) }
    it { should have_many(:grades).dependent(:destroy) }
    it { should have_many(:absences).through(:subjects) }
    it { should have_many(:class_schedules).dependent(:destroy) }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:calendars).dependent(:destroy) }

    it { should have_many(:students).class_name('User') }
    it { should have_many(:teachers).class_name('User') }
    it { should have_many(:directions).class_name('User') }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:cnpj) }
    it { should validate_presence_of(:address) }
    it { should validate_uniqueness_of(:cnpj) }
  end

  describe "methods" do
    let(:school) { create(:school) }

    describe "#direction" do
      it "returns the first direction user" do
        direction = create(:user, :direction, school: school)
        expect(school.direction).to eq(direction)
      end
    end

    describe "#total_students" do
      it "returns count of students" do
        create_list(:user, 3, :student, school: school)

        expect(school.total_students).to eq(3)
      end
    end

    describe "#total_teachers" do
      it "returns count of teachers" do
        create_list(:user, 2, :teacher, school: school)

        expect(school.total_teachers).to eq(2)
      end
    end

    describe "#total_classrooms" do
      it "returns count of classrooms" do
        create_list(:classroom, 4, school: school)

        expect(school.total_classrooms).to eq(4)
      end
    end
  end
end
