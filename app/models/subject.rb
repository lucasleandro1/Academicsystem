class Subject < ApplicationRecord
  belongs_to :classroom
  belongs_to :teacher, class_name: "User", foreign_key: "user_id"
  belongs_to :school

  has_many :activities, dependent: :destroy
  has_many :grades, dependent: :destroy
  has_many :absences, dependent: :destroy
  has_many :class_schedules, dependent: :destroy

  validates :name, :workload, presence: true
  validates :name, uniqueness: { scope: [ :classroom_id, :school_id ] }
  validates :workload, numericality: { greater_than: 0 }

  def students
    classroom.students
  end

  def average_grade_by_bimester(bimester)
    grades.where(bimester: bimester).average(:value)
  end
end
