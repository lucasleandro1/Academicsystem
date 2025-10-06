# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe "associations" do
    it { should belong_to(:school).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:calendar_type) }
  end

  describe "scopes" do
    let(:school) { create(:school) }
    let!(:municipal_calendar) { create(:calendar, all_schools: true, school: nil) }
    let!(:school_calendar) { create(:calendar, school: school, all_schools: false) }
    let!(:future_calendar) { create(:calendar, date: 1.week.from_now) }
    let!(:past_calendar) { create(:calendar, date: 1.week.ago) }

    describe ".municipal" do
      it "returns only municipal calendars" do
        expect(Calendar.municipal).to include(municipal_calendar)
        expect(Calendar.municipal).not_to include(school_calendar)
      end
    end

    describe ".for_school" do
      it "returns calendars for specific school" do
        expect(Calendar.for_school(school)).to include(school_calendar)
        expect(Calendar.for_school(school)).not_to include(municipal_calendar)
      end
    end

    describe ".upcoming" do
      it "returns only future calendars" do
        expect(Calendar.upcoming).to include(future_calendar)
        expect(Calendar.upcoming).not_to include(past_calendar)
      end
    end

    describe ".past" do
      it "returns only past calendars" do
        expect(Calendar.past).to include(past_calendar)
        expect(Calendar.past).not_to include(future_calendar)
      end
    end
  end

  describe "constants" do
    it "defines CALENDAR_TYPES" do
      expected_types = [
        "holiday", "municipal_holiday", "vacation", "school_start",
        "school_end", "exam_period", "meeting", "pedagogical_day", "teacher_training"
      ]
      expect(Calendar::CALENDAR_TYPES).to include(*expected_types)
    end
  end
end
