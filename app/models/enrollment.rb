class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :classroom

  validates :status, inclusion: { in: %w[pending active inactive rejected] }
  validates :user_id, uniqueness: { scope: :classroom_id }
  validate :student_must_be_student

  enum :status, {
    pending: "pending",
    active: "active",
    inactive: "inactive",
    rejected: "rejected"
  }

  scope :current_year, -> { joins(:classroom).where(classrooms: { academic_year: Date.current.year }) }

  def school
    classroom.school
  end

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end
end
