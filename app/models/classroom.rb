class Classroom < ApplicationRecord
  belongs_to :school
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
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
    enrollments.where(status: "active").count
  end
end
