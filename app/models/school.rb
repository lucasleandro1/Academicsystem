class School < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :classrooms, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :subjects, dependent: :destroy
  has_many :grades, dependent: :destroy
  has_many :absences, through: :subjects
  has_many :class_schedules, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :calendars, dependent: :destroy

  has_many :students, -> { where(user_type: "student") }, class_name: "User"
  has_many :teachers, -> { where(user_type: "teacher") }, class_name: "User"
  has_many :directions, -> { where(user_type: "direction") }, class_name: "User"

  validates :name, :cnpj, :address, presence: true
  validates :cnpj, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def direction
    directions.first
  end

  def total_students
    students.count
  end

  def total_teachers
    teachers.count
  end

  def total_classrooms
    classrooms.count
  end

  def total_subjects
    subjects.count
  end

  def active_events
    events.where("start_date >= ?", Date.current)
  end
end
