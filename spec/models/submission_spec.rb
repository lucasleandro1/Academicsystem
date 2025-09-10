# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model do
  describe "associations" do
    it { should belong_to(:activity) }
    it { should belong_to(:student).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:school) }
  end

  describe "validations" do
    it { should validate_presence_of(:answer) }
  end

  describe "scopes" do
    let!(:graded_submission) { create(:submission, :graded) }
    let!(:ungraded_submission) { create(:submission, :ungraded) }
    let!(:old_submission) { create(:submission, submission_date: 2.days.ago) }
    let!(:recent_submission) { create(:submission, submission_date: 1.hour.ago) }

    describe ".graded" do
      it "returns only graded submissions" do
        expect(Submission.graded).to include(graded_submission)
        expect(Submission.graded).not_to include(ungraded_submission)
      end
    end

    describe ".ungraded" do
      it "returns only ungraded submissions" do
        expect(Submission.ungraded).to include(ungraded_submission)
        expect(Submission.ungraded).not_to include(graded_submission)
      end
    end

    describe ".recent" do
      it "orders submissions by submission_date desc" do
        expect(Submission.recent.first.submission_date).to be >= Submission.recent.last.submission_date
      end
    end
  end

  describe "custom validations" do
    describe "#student_must_be_student" do
      it "validates that user is a student" do
        teacher = create(:user, :teacher)
        submission = build(:submission, student: teacher)

        expect(submission).not_to be_valid
        expect(submission.errors[:student]).to include("deve ser um aluno")
      end

      it "allows valid student" do
        student = create(:user, :student)
        submission = build(:submission, student: student)

        expect(submission).to be_valid
      end
    end
  end
end
