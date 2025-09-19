class Subject < ApplicationRecord
  belongs_to :classroom, optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
  belongs_to :school

  has_many :activities, dependent: :destroy
  has_many :grades, dependent: :destroy
  has_many :absences, dependent: :destroy
  has_many :class_schedules, dependent: :destroy
  has_many :submissions, through: :activities

  validates :name, :workload, presence: true
  validates :name, uniqueness: { scope: [ :school_id ] }
  validates :workload, numericality: { greater_than: 0 }
  validates :code, uniqueness: { scope: :school_id }, allow_blank: true
  validates :area, inclusion: {
    in: %w[languages mathematics natural_sciences human_sciences religious_education physical_education arts technology],
    allow_blank: true
  }
  validate :teacher_must_be_teacher

  scope :by_teacher, ->(teacher) { where(user_id: teacher.id) }
  scope :by_classroom, ->(classroom) { where(classroom: classroom) }
  scope :by_area, ->(area) { where(area: area) }

  def teacher
    user
  end

  def students
    classroom&.students || User.none
  end

  def average_grade_by_bimester(bimester)
    grades.where(bimester: bimester).average(:value)&.round(2)
  end

  def attendance_rate
    return 100.0 if students.empty?

    total_possible_attendances = students.count * workload
    return 100.0 if total_possible_attendances.zero?

    total_absences = absences.count
    ((total_possible_attendances - total_absences).to_f / total_possible_attendances * 100).round(2)
  end

  def activity_completion_rate
    return 0.0 if activities.empty? || students.empty?

    total_possible_submissions = activities.count * students.count
    return 0.0 if total_possible_submissions.zero?

    total_submissions = submissions.count
    (total_submissions.to_f / total_possible_submissions * 100).round(2)
  end

  private

  def teacher_must_be_teacher
    return if user_id.blank?

    user_record = User.find_by(id: user_id)
    return errors.add(:user_id, "não encontrado") unless user_record

    unless user_record.teacher?
      return errors.add(:user_id, "deve ser um professor")
    end

    unless user_record.school_id == school_id
      errors.add(:user_id, "deve ser um professor desta escola")
    end
  end
end
