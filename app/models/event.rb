class Event < ApplicationRecord
  belongs_to :school, optional: true

  validates :title, presence: true
  validates_presence_of :start_date, unless: :event_date
  validates_presence_of :event_date, unless: :start_date
  validates :event_type, inclusion: { in: %w[academico cultural esportivo administrativo reuniao feriado general meeting holiday academic celebration training other] }, allow_blank: true
  validate :end_date_after_start_date
  validate :end_time_after_start_time
  validate :school_or_municipal

  before_save :sync_date_fields

  scope :upcoming, -> { where("COALESCE(start_date, event_date) >= ?", Date.current) }
  scope :past, -> { where("COALESCE(start_date, event_date) < ?", Date.current) }
  scope :current, -> { where("COALESCE(start_date, event_date) = ?", Date.current) }
  scope :municipal, -> { where(is_municipal: true) }
  scope :school_only, -> { where(is_municipal: false) }
  scope :by_type, ->(type) { where(event_type: type) }

  def municipal?
    is_municipal == true
  end

  def upcoming?
    date = start_date || event_date
    return false if date.nil?
    date >= Date.current
  end

  def current?
    date = start_date || event_date
    return false if date.nil?
    date == Date.current
  end

  def past?
    date = start_date || event_date
    return false if date.nil?
    date < Date.current
  end

  def status
    return "completed" if past?
    return "ongoing" if current?
    return "planned" if upcoming?
    "planned"
  end

  def duration_days
    start_dt = start_date || event_date
    end_dt = end_date || event_date
    return 1 if end_dt.nil?
    (end_dt - start_dt).to_i + 1
  end

  def formatted_date
    start_dt = start_date || event_date
    end_dt = end_date || event_date
    if start_dt == end_dt || end_dt.nil?
      start_dt&.strftime("%d/%m/%Y") || "N/A"
    else
      "#{formatted_start_date} a #{formatted_end_date}"
    end
  end

  def formatted_start_date
    (start_date || event_date)&.strftime("%d/%m/%Y") || "N/A"
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

  def sync_date_fields
    # Se start_date foi definido mas event_date não, copiar start_date para event_date
    if start_date.present? && event_date.blank?
      self.event_date = start_date
    # Se event_date foi definido mas start_date não, copiar event_date para start_date e end_date
    elsif event_date.present? && start_date.blank?
      self.start_date = event_date
      self.end_date = event_date if end_date.blank?
    end
  end

  def end_date_after_start_date
    start_dt = start_date || event_date
    return unless start_dt && end_date

    if end_date < start_dt
      errors.add(:end_date, "deve ser posterior à data de início")
    end
  end

  def end_time_after_start_time
    start_dt = start_date || event_date
    return unless start_time && end_time && (end_date.nil? || start_dt == end_date)

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end

  def school_or_municipal
    if school_id.nil? && !is_municipal
      errors.add(:school, "deve ser selecionada ou o evento deve ser municipal")
    end
  end
end
