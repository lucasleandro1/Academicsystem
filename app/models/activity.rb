class Activity < ApplicationRecord
  belongs_to :subject
  belongs_to :teacher, class_name: "User", foreign_key: "user_id"
  belongs_to :school

  has_many :submissions, dependent: :destroy
  has_many :submitted_students, through: :submissions, source: :student

  scope :recent, -> { order(created_at: :desc) }
  scope :upcoming, -> { where("due_date > ?", Time.current) }
  scope :overdue, -> { where("due_date < ?", Time.current) }

  validates :title, :description, presence: true
  validate :teacher_must_be_teacher
  validate :teacher_teaches_subject

  def students
    subject.students
  end

  def submission_rate
    return 0 if students.count.zero?
    (submissions.count.to_f / students.count * 100).round(2)
  end

  def overdue?
    due_date&.past?
  end

  private

  def teacher_must_be_teacher
    errors.add(:teacher, "deve ser um professor") unless teacher&.teacher?
  end

  def teacher_teaches_subject
    return unless teacher&.teacher? && subject

    unless teacher.teacher_subjects.include?(subject)
      errors.add(:teacher, "deve lecionar esta disciplina")
    end
  end
end
