# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:sender).class_name('User') }
    it { should belong_to(:school).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:notification_type) }
  end

  describe "scopes" do
    let(:user) { create(:user, :student) }
    let!(:read_notification) { create(:notification, user: user, read: true) }
    let!(:unread_notification) { create(:notification, user: user, read: false) }
    let!(:old_notification) { create(:notification, user: user, created_at: 2.days.ago) }
    let!(:recent_notification) { create(:notification, user: user, created_at: 1.hour.ago) }

    describe ".unread" do
      it "returns only unread notifications" do
        expect(Notification.unread).to include(unread_notification)
        expect(Notification.unread).not_to include(read_notification)
      end
    end

    describe ".recent" do
      it "orders notifications by created_at desc" do
        expect(Notification.recent.first.created_at).to be >= Notification.recent.last.created_at
      end
    end
  end
end
