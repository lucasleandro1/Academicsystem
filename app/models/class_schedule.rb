class ClassSchedule < ApplicationRecord
  belongs_to :classroom
  belongs_to :subject
  belongs_to :school

  validates :weekday, :start_time, :end_time, presence: true
  validates :weekday, inclusion: { in: 0..6 } # 0=Domingo, 1=Segunda, ..., 6=Sábado
  validates :period, inclusion: { in: %w[matutino vespertino noturno] }, allow_blank: true
  validates :class_order, numericality: { greater_than: 0 }, allow_blank: true
  validate :end_time_after_start_time
  validate :subject_belongs_to_classroom
  validate :no_time_conflict

  scope :by_weekday, ->(day) { where(weekday: day) }
  scope :by_time, -> { order(:start_time) }
  scope :by_period, ->(period) { where(period: period) }
  scope :for_classroom, ->(classroom) { where(classroom: classroom) }
  scope :for_subject, ->(subject) { where(subject: subject) }
  scope :active, -> { where(active: true) }
  scope :weekly_schedule, -> { order(:weekday, :start_time) }

  def weekday_name
    case weekday
    when 0 then "Domingo"
    when 1 then "Segunda-feira"
    when 2 then "Terça-feira"
    when 3 then "Quarta-feira"
    when 4 then "Quinta-feira"
    when 5 then "Sexta-feira"
    when 6 then "Sábado"
    else "Dia não definido"
    end
  end

  def weekday_short
    case weekday
    when 0 then "Dom"
    when 1 then "Seg"
    when 2 then "Ter"
    when 3 then "Qua"
    when 4 then "Qui"
    when 5 then "Sex"
    when 6 then "Sáb"
    else "N/D"
    end
  end

  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  def period_display
    case period
    when "matutino"
      "Manhã"
    when "vespertino"
      "Tarde"
    when "noturno"
      "Noite"
    else
      "-"
    end
  end

  def display_info
    info = "#{subject.name} - #{weekday_name} #{time_range}"
    info += " (#{class_order}ª aula)" if class_order.present?
    info += " - #{period.humanize}" if period.present?
    info
  end

  def duration_in_minutes
    ((end_time - start_time) / 1.minute).to_i
  end

  alias_method :duration, :duration_in_minutes

  def teacher
    subject.teacher
  end

  def classroom_location
    classroom&.name
  end

  def self.grid_for_classroom(classroom)
    schedules = for_classroom(classroom).active.includes(:subject)
    grid = {}

    (1..6).each do |day|
      grid[day] = schedules.where(weekday: day).order(:start_time)
    end

    grid
  end

  def self.schedule_for_teacher(teacher)
    joins(:subject).where(subjects: { user_id: teacher.id }).active.order(:weekday, :start_time)
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

    # Verifica se a disciplina pertence à mesma escola da turma
    unless subject.school_id == classroom.school_id
      errors.add(:subject, "deve pertencer à mesma escola da turma")
    end
  end

  def no_time_conflict
    return unless classroom && weekday && start_time && end_time

    conflicting = ClassSchedule.where(
      classroom: classroom,
      weekday: weekday,
      active: true
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
