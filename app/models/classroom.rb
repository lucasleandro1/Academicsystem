class Classroom < ApplicationRecord
  belongs_to :school
  has_many :students, -> { where(user_type: "student") }, class_name: "User", foreign_key: "classroom_id", dependent: :nullify
  has_many :subjects, dependent: :destroy
  has_many :class_schedules, dependent: :destroy
  has_many :teachers, through: :subjects, source: :user
  has_many :grades, through: :subjects
  has_many :absences, through: :subjects

  validates :name, :academic_year, :shift, :level, presence: true
  validates :name, uniqueness: { scope: :school_id }
  validates :academic_year, numericality: { greater_than: 2000, less_than_or_equal_to: Date.current.year + 1 }

  enum :shift, { morning: "morning", afternoon: "afternoon", evening: "evening" }
  enum :level, {
    elementary_1: "elementary_1",
    elementary_2: "elementary_2",
    high_school: "high_school"
  }

  scope :current_year, -> { where(academic_year: Date.current.year) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_shift, ->(shift) { where(shift: shift) }

  def display_name
    "#{name} - #{academic_year} (#{shift.humanize})"
  end

  def simple_name
    "#{name} - #{academic_year}"
  end

  def student_count
    students.count
  end

  def subject_count
    subjects.count
  end

  def weekly_schedule
    class_schedules.includes(:subject).order(:weekday, :start_time)
  end

  def schedule_by_day(weekday)
    class_schedules.includes(:subject).where(weekday: weekday).order(:start_time)
  end

  def subjects_from_schedules
    # Buscar disciplinas através dos horários desta turma
    Subject.joins(:class_schedules)
           .where(class_schedules: { classroom: self })
           .distinct
  end

  def average_attendance_rate
    return 0 if students.empty?

    total_classes = subjects.sum(:workload)
    return 0 if total_classes.zero?

    total_absences = absences.count
    total_possible_attendances = students.count * total_classes

    return 0 if total_possible_attendances.zero?

    ((total_possible_attendances - total_absences).to_f / total_possible_attendances * 100).round(2)
  end
end
