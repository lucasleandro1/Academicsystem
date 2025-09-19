class Grade < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :subject
  belongs_to :school

  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bimester, presence: true, inclusion: { in: [ 1, 2, 3, 4 ] }
  validates :grade_type, presence: true
  validates :assessment_name, presence: true
  validates :assessment_date, presence: true
  validates :user_id, uniqueness: { scope: [ :subject_id, :bimester, :grade_type, :assessment_name ] }
  validate :student_must_be_student
  validate :student_belongs_to_subject_classroom
  validate :value_cannot_exceed_max_value

  scope :by_bimester, ->(bimester) { where(bimester: bimester) }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }
  scope :by_grade_type, ->(type) { where(grade_type: type) }
  scope :recent, -> { order(assessment_date: :desc) }
  scope :current_bimester, -> { where(bimester: current_bimester_number) }

  enum :grade_type, {
    prova: "prova",
    trabalho: "trabalho",
    atividade: "atividade",
    participacao: "participacao",
    projeto: "projeto",
    recuperacao: "recuperacao"
  }

  def percentage
    return 0 if max_value.zero?
    (value / max_value * 100).round(2)
  end

  def passed?
    percentage >= 60.0
  end

  def display_grade
    "#{value}/#{max_value} (#{percentage}%)"
  end

  def self.current_bimester_number
    month = Date.current.month
    case month
    when 1..3 then 1
    when 4..6 then 2
    when 7..9 then 3
    when 10..12 then 4
    end
  end

  def self.average_by_bimester_and_subject(student_id, subject_id, bimester)
    where(user_id: student_id, subject_id: subject_id, bimester: bimester)
      .average(:value)&.round(2)
  end

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end

  def student_belongs_to_subject_classroom
    return unless student&.student? && subject&.classroom_id

    if student.classroom_id != subject.classroom_id
      errors.add(:student, "deve pertencer à turma da disciplina")
    end
  end

  def value_cannot_exceed_max_value
    return unless value.present? && max_value.present?

    if value > max_value
      errors.add(:value, "não pode ser maior que a nota máxima (#{max_value})")
    end
  end
end
