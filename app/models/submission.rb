class Submission < ApplicationRecord
  belongs_to :activity
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :school

  validates :answer, presence: true
  validate :student_must_be_student

  scope :graded, -> { where.not(teacher_grade: nil) }
  scope :ungraded, -> { where(teacher_grade: nil) }
  scope :recent, -> { order(submission_date: :desc) }

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end
end
