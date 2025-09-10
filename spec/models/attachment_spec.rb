# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  describe "associations" do
    it { should belong_to(:attachable) }
    it { should belong_to(:school) }
  end

  describe "polymorphic association" do
    it "can belong to different types of objects" do
      document = create(:document)
      attachment = create(:attachment, attachable: document)

      expect(attachment.attachable).to eq(document)
      expect(attachment.attachable_type).to eq('Document')
    end
  end
end
