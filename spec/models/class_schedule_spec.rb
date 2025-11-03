# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClassSchedule, type: :model do
  describe "associations" do
    it { should belong_to(:classroom) }
    it { should belong_to(:subject) }
    it { should belong_to(:school) }
  end

  describe "validations" do
    it { should validate_presence_of(:weekday) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_inclusion_of(:weekday).in_array(%w[sunday monday tuesday wednesday thursday friday saturday]) }
  end

  describe "enums" do
    it { should define_enum_for(:weekday).with_values(
      sunday: 0,
      monday: 1,
      tuesday: 2,
      wednesday: 3,
      thursday: 4,
      friday: 5,
      saturday: 6
    )}
  end

  describe "scopes" do
    let!(:monday_schedule) { create(:class_schedule, :monday) }
    let!(:tuesday_schedule) { create(:class_schedule, :tuesday) }
    let!(:morning_schedule) { create(:class_schedule, :morning_schedule) }
    let!(:afternoon_schedule) { create(:class_schedule, :afternoon_schedule) }

    describe ".by_weekday" do
      it "filters schedules by weekday" do
        expect(ClassSchedule.by_weekday(1)).to include(monday_schedule)
        expect(ClassSchedule.by_weekday(1)).not_to include(tuesday_schedule)
      end
    end

    describe ".by_time" do
      it "orders schedules by start_time" do
        schedules = ClassSchedule.by_time
        expect(schedules.first.start_time).to be <= schedules.last.start_time
      end
    end
  end

  describe "custom validations" do
    describe "#end_time_after_start_time" do
      it "validates that end_time is after start_time" do
        schedule = build(:class_schedule, start_time: "10:00", end_time: "09:00")

        expect(schedule).not_to be_valid
        expect(schedule.errors[:end_time]).to be_present
      end

      it "allows valid time range" do
        schedule = build(:class_schedule, start_time: "08:00", end_time: "09:00")

        expect(schedule).to be_valid
      end
    end
  end

  describe "#period_display" do
    it "returns 'Manhã' for matutino period" do
      schedule = build(:class_schedule, period: "matutino")
      expect(schedule.period_display).to eq("Manhã")
    end

    it "returns 'Tarde' for vespertino period" do
      schedule = build(:class_schedule, period: "vespertino")
      expect(schedule.period_display).to eq("Tarde")
    end

    it "returns 'Noite' for noturno period" do
      schedule = build(:class_schedule, period: "noturno")
      expect(schedule.period_display).to eq("Noite")
    end

    it "returns '-' for nil period" do
      schedule = build(:class_schedule, period: nil)
      expect(schedule.period_display).to eq("-")
    end

    it "returns '-' for empty period" do
      schedule = build(:class_schedule, period: "")
      expect(schedule.period_display).to eq("-")
    end

    it "returns '-' for unknown period" do
      schedule = build(:class_schedule, period: "unknown")
      expect(schedule.period_display).to eq("-")
    end
  end
end
