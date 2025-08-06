class Occurrence < ApplicationRecord
  belongs_to :student, -> { where(user_type: "student") }, class_name: "User", foreign_key: "user_id"
  belongs_to :author, polymorphic: true
  belongs_to :school

  validates :description, :occurrence_type, :date, presence: true
  validates :occurrence_type, inclusion: { in: %w[disciplinary academic positive] }

  enum :occurrence_type, {
    disciplinary: "disciplinary",
    academic: "academic",
    positive: "positive"
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(occurrence_type: type) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }

  def author_name
    author.try(:full_name) || "Sistema"
  end

  def severity_color
    case occurrence_type
    when "positive"
      "success"
    when "academic"
      "warning"
    when "disciplinary"
      "danger"
    else
      "secondary"
    end
  end
end
