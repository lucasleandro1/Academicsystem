class Grade < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :subject

  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :bimester, presence: true, inclusion: { in: [ 1, 2, 3, 4 ] }
  validates :grade_type, presence: true
  validates :user_id, uniqueness: { scope: [ :subject_id, :bimester, :grade_type ] }
  validate :student_must_be_student

  scope :by_bimester, ->(bimester) { where(bimester: bimester) }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }
  scope :recent, -> { order(created_at: :desc) }

  enum :grade_type, {
    prova: "prova",
    trabalho: "trabalho",
    atividade: "atividade",
    participacao: "participacao",
    projeto: "projeto"
  }

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end
end
