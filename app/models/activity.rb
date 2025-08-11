class Activity < ApplicationRecord
  belongs_to :subject
  belongs_to :teacher, class_name: "User", foreign_key: "user_id"
  belongs_to :school

  has_many :submissions, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }

  validates :title, :description, presence: true
  validate :teacher_must_be_teacher

  private

  def teacher_must_be_teacher
    errors.add(:teacher, "deve ser um professor") unless teacher&.teacher?
  end
end
