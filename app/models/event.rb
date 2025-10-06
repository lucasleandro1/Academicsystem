class Event < ApplicationRecord
  belongs_to :school

  validates :title, presence: true
  validates :start_date, presence: true
  validates :event_type, inclusion: { in: %w[academico cultural esportivo administrativo reuniao feriado] }, allow_blank: true
  validate :end_date_after_start_date
  validate :end_time_after_start_time

  scope :upcoming, -> { where("start_date >= ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }
  scope :current, -> { where("start_date <= ? AND (end_date >= ? OR end_date IS NULL)", Date.current, Date.current) }
  scope :municipal, -> { where(is_municipal: true) }
  scope :school_only, -> { where(is_municipal: false) }
  scope :by_type, ->(type) { where(event_type: type) }

  def municipal?
    is_municipal == true
  end

  def upcoming?
    return false if start_date.nil?
    start_date >= Date.current
  end

  def current?
    return false if start_date.nil?
    start_date <= Date.current && (end_date.nil? || end_date >= Date.current)
  end

  def past?
    return false if end_date.nil?
    end_date < Date.current
  end

  def status
    return "completed" if past?
    return "ongoing" if current?
    return "planned" if upcoming?
    "planned"
  end

  def duration_days
    return 1 if end_date.nil?
    (end_date - start_date).to_i + 1
  end

  def formatted_date
    if start_date == end_date || end_date.nil?
      start_date&.strftime("%d/%m/%Y") || "N/A"
    else
      "#{formatted_start_date} a #{formatted_end_date}"
    end
  end

  def formatted_start_date
    start_date&.strftime("%d/%m/%Y") || "N/A"
  end

  def formatted_end_date
    end_date&.strftime("%d/%m/%Y") || "N/A"
  end

  def formatted_start_time
    start_time&.strftime("%H:%M") || "Não definido"
  end

  def formatted_end_time
    end_time&.strftime("%H:%M") || "Não definido"
  end

  def time_range
    return "Horário não definido" if start_time.nil?
    return formatted_start_time if end_time.nil?
    "#{formatted_start_time} - #{formatted_end_time}"
  end

  def formatted_created_at
    created_at&.strftime("%d/%m/%Y às %H:%M") || "Data não disponível"
  end

  def formatted_updated_at
    updated_at&.strftime("%d/%m/%Y às %H:%M") || "Data não disponível"
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "deve ser posterior à data de início")
    end
  end

  def end_time_after_start_time
    return unless start_time && end_time && (end_date.nil? || start_date == end_date)

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end
end
