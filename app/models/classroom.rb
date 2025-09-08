class Classroom < ApplicationRecord
  belongs_to :school
  has_many :students, -> { where(user_type: "student") }, class_name: "User", foreign_key: "classroom_id"
  has_many :subjects, dependent: :destroy
  has_many :class_schedules, dependent: :destroy

  validates :name, :academic_year, :shift, :level, presence: true
  validates :name, uniqueness: { scope: :school_id }

  enum :shift, { morning: "morning", afternoon: "afternoon", evening: "evening" }
  enum :level, {
    elementary_1: "elementary_1",
    elementary_2: "elementary_2",
    high_school: "high_school"
  }

  def display_name
    "#{name} - #{academic_year} (#{shift.humanize})"
  end

  def student_count
    students.count
  end
end
