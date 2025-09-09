# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:sender).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
    it { should belong_to(:school) }
  end

  describe "validations" do
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:body) }
  end

  describe "scopes" do
    let(:user) { create(:user, :student) }
    let!(:read_message) { create(:message, :read, recipient: user) }
    let!(:unread_message) { create(:message, :unread, recipient: user) }
    let!(:old_message) { create(:message, recipient: user, created_at: 2.days.ago) }
    let!(:recent_message) { create(:message, recipient: user, created_at: 1.hour.ago) }

    describe ".unread" do
      it "returns only unread messages" do
        expect(Message.where(read_at: nil)).to include(unread_message)
        expect(Message.where(read_at: nil)).not_to include(read_message)
      end
    end

    describe "ordering by created_at" do
      it "can be ordered by created_at desc" do
        messages = Message.order(created_at: :desc)
        expect(messages.first.created_at).to be >= messages.last.created_at
      end
    end
  end
end
