class ClassSchedule < ApplicationRecord
  belongs_to :classroom
  belongs_to :subject
  belongs_to :school

  validates :weekday, :start_time, :end_time, presence: true
  validates :weekday, inclusion: { in: 0..6 } # 0 = domingo, 6 = sábado
  validate :end_time_after_start_time

  enum :weekday, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }

  scope :by_weekday, ->(day) { where(weekday: day) }
  scope :by_time, -> { order(:start_time) }

  def weekday_name
    Date::DAYNAMES[weekday]
  end

  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end
end
