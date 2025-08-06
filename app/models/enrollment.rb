class Enrollment < ApplicationRecord
  belongs_to :student, -> { where(user_type: "student") }, class_name: "User", foreign_key: "user_id"
  belongs_to :classroom

  validates :status, inclusion: { in: %w[pending active inactive rejected] }
  validates :user_id, uniqueness: { scope: :classroom_id }

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
end
