class Submission < ApplicationRecord
  belongs_to :activity
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :school

  validates :answer, presence: true
  validate :student_must_be_student
  validate :student_belongs_to_activity_classroom
  validates :user_id, uniqueness: { scope: :activity_id }

  scope :graded, -> { where.not(teacher_grade: nil) }
  scope :ungraded, -> { where(teacher_grade: nil) }
  scope :recent, -> { order(submission_date: :desc) }

  def graded?
    teacher_grade.present?
  end

  def late?
    return false unless activity.due_date && submission_date
    submission_date > activity.due_date
  end

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end

  def student_belongs_to_activity_classroom
    return unless student&.student? && activity&.subject&.classroom_id

    if student.classroom_id != activity.subject.classroom_id
      errors.add(:student, "deve pertencer à turma da atividade")
    end
  end
end
