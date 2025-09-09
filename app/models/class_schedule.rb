class ClassSchedule < ApplicationRecord
  belongs_to :classroom
  belongs_to :subject
  belongs_to :school

  validates :weekday, :start_time, :end_time, presence: true
  validates :weekday, inclusion: { in: %w[sunday monday tuesday wednesday thursday friday saturday] }
  validate :end_time_after_start_time
  validate :subject_belongs_to_classroom
  validate :no_time_conflict

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
  scope :for_classroom, ->(classroom) { where(classroom: classroom) }

  def weekday_name
    Date::DAYNAMES[weekday]
  end

  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  def display_info
    "#{subject.name} - #{weekday_name} #{time_range}"
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end

  def subject_belongs_to_classroom
    return unless subject && classroom

    errors.add(:subject, "deve pertencer à turma") unless subject.classroom_id == classroom.id
  end

  def no_time_conflict
    return unless classroom && weekday && start_time && end_time

    conflicting = ClassSchedule.where(
      classroom: classroom,
      weekday: weekday
    ).where.not(id: id).where(
      "(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
      end_time, start_time,
      start_time, end_time,
      start_time, end_time
    )

    if conflicting.exists?
      errors.add(:base, "Conflito de horário com outra disciplina")
    end
  end
end
