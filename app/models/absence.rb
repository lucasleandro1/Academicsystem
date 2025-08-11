class Absence < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "user_id"
  belongs_to :subject

  validates :date, presence: true
  validate :student_must_be_student

  scope :justified, -> { where(justified: true) }
  scope :unjustified, -> { where(justified: false) }
  scope :recent, -> { order(date: :desc) }

  private

  def student_must_be_student
    errors.add(:student, "deve ser um aluno") unless student&.student?
  end
end
