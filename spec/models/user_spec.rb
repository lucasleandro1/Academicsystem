require 'rails_helper'

RSpec.describe User do
  describe "enum user_type" do
    it "acept valid types" do
      expect(build(:user, :student).user_type).to eq("student")
      expect(build(:user, :teacher).user_type).to eq("teacher")
      expect(build(:user, :direction).user_type).to eq("direction")
      expect(build(:user, :admin).user_type).to eq("admin")
    end
  end

  describe "auto associations with after_create" do
    it "when user_type direction" do
      user = create(:user, :direction)
      expect(user.direction).to be_present
    end

    it "when user_type teacher" do
      user = create(:user, :teacher)
      expect(user.teacher).to be_present
    end

    it "when user_type student" do
      user = create(:user, :student)
      expect(user.student).to be_present
    end
  end
end
