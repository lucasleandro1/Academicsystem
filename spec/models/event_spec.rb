# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "associations" do
    it { should belong_to(:school) }
  end

  describe "methods" do
    describe "#municipal?" do
      it "returns true when is_municipal is true" do
        event = build(:event, is_municipal: true)
        expect(event.municipal?).to be true
      end

      it "returns false when is_municipal is false" do
        event = build(:event, is_municipal: false)
        expect(event.municipal?).to be false
      end

      it "returns false when is_municipal is nil" do
        event = build(:event, is_municipal: nil)
        expect(event.municipal?).to be false
      end
    end

    describe "#upcoming?" do
      it "returns true for future events" do
        event = build(:event, event_date: 1.week.from_now.to_date)
        expect(event.upcoming?).to be true
      end

      it "returns false for past events" do
        event = build(:event, event_date: 1.week.ago.to_date)
        expect(event.upcoming?).to be false
      end

      it "returns true for today's events" do
        event = build(:event, event_date: Date.current)
        expect(event.upcoming?).to be true
      end

      it "returns false when event_date is nil" do
        event = build(:event, event_date: nil)
        expect(event.upcoming?).to be false
      end
    end

    describe "#formatted_date" do
      it "returns formatted date string" do
        event = build(:event, event_date: Date.new(2024, 12, 25))
        expect(event.formatted_date).to eq("25/12/2024")
      end

      it "returns 'N/A' when event_date is nil" do
        event = build(:event, event_date: nil)
        expect(event.formatted_date).to eq("N/A")
      end
    end
  end
end
