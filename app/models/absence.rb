class Absence < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :subject

  delegate :school, to: :subject

  validates :date, presence: true
  validates :justification, presence: true, if: :justified?
  validate :student_must_be_student
  validate :student_belongs_to_subject_classroom
  validate :date_cannot_be_future

  scope :justified, -> { where(justified: true) }
  scope :unjustified, -> { where(justified: false) }
  scope :recent, -> { order(date: :desc) }
  scope :by_month, ->(month, year) { where(date: Date.new(year, month).beginning_of_month..Date.new(year, month).end_of_month) }

  def class_schedule
    return nil unless date && subject

    weekday = date.wday
    ClassSchedule.find_by(subject: subject, weekday: weekday, active: true)
  end

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end

  def student_belongs_to_subject_classroom
    return unless student&.student? && subject

    # Se a disciplina tem uma turma específica, verificar se o aluno pertence a ela
    if subject.classroom_id.present?
      if student.classroom_id != subject.classroom_id
        errors.add(:student, "deve pertencer à turma da disciplina")
      end
    else
      # Se a disciplina não tem turma específica (atende múltiplas turmas),
      # verificar se o aluno pertence a alguma turma que a disciplina atende
      available_classroom_ids = subject.available_classrooms.pluck(:id)
      unless available_classroom_ids.include?(student.classroom_id)
        errors.add(:student, "deve pertencer a uma turma atendida pela disciplina")
      end
    end
  end

  def date_cannot_be_future
    errors.add(:date, "não pode ser no futuro") if date&.future?
  end
end
