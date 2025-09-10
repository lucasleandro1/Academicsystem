class ClassSchedule < ApplicationRecord
  belongs_to :classroom
  belongs_to :subject
  belongs_to :school

  validates :weekday, :start_time, :end_time, presence: true
  validates :weekday, inclusion: { in: 1..6 }
  validate :end_time_after_start_time
  validate :subject_belongs_to_classroom
  validate :no_time_conflict

  scope :by_weekday, ->(day) { where(weekday: day) }
  scope :by_time, -> { order(:start_time) }
  scope :for_classroom, ->(classroom) { where(classroom: classroom) }

  def weekday_name
    case weekday
    when 1 then "Segunda-feira"
    when 2 then "Terça-feira"
    when 3 then "Quarta-feira"
    when 4 then "Quinta-feira"
    when 5 then "Sexta-feira"
    when 6 then "Sábado"
    else "Dia não definido"
    end
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
