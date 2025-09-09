# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe "associations" do
    it { should belong_to(:subject) }
    it { should belong_to(:teacher).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:school) }
    it { should have_many(:submissions).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end

  describe "scopes" do
    let!(:old_activity) { create(:activity, created_at: 2.days.ago) }
    let!(:recent_activity) { create(:activity, created_at: 1.hour.ago) }

    describe ".recent" do
      it "orders activities by created_at desc" do
        expect(Activity.recent.first.created_at).to be >= Activity.recent.last.created_at
      end
    end
  end

  describe "custom validations" do
    describe "#teacher_must_be_teacher" do
      it "validates that user is a teacher" do
        student = create(:user, :student)
        activity = build(:activity, teacher: student)

        expect(activity).not_to be_valid
        expect(activity.errors[:teacher]).to include("deve ser um professor")
      end

      it "allows valid teacher" do
        teacher = create(:user, :teacher)
        activity = build(:activity, teacher: teacher)

        expect(activity).to be_valid
      end
    end
  end
end
