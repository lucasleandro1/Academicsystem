class Calendar < ApplicationRecord
  belongs_to :school, optional: true

  validates :title, presence: true
  validates :date, presence: true
  validates :calendar_type, presence: true

  scope :municipal, -> { where(all_schools: true) }
  scope :for_school, ->(school) { where(school: school) }
  scope :upcoming, -> { where("date >= ?", Date.current) }
  scope :past, -> { where("date < ?", Date.current) }

  CALENDAR_TYPES = [
    "holiday",           # Feriado
    "municipal_holiday", # Feriado Municipal
    "vacation",          # Férias
    "school_start",      # Início das Aulas
    "school_end",        # Fim das Aulas
    "exam_period",       # Período de Provas
    "meeting",           # Reunião
    "pedagogical_day",   # Dia Pedagógico
    "teacher_training",  # Formação de Professores
    "event",             # Evento Especial
    "deadline",          # Prazo
    "suspension"         # Suspensão das Aulas
  ].freeze

  def municipal?
    all_schools == true
  end

  def upcoming?
    date >= Date.current
  end

  def formatted_date
    date.strftime("%d/%m/%Y")
  end

  def type_description
    case calendar_type
    when "holiday" then "Feriado Nacional"
    when "municipal_holiday" then "Feriado Municipal"
    when "vacation" then "Férias"
    when "school_start" then "Início das Aulas"
    when "school_end" then "Fim das Aulas"
    when "exam_period" then "Período de Provas"
    when "meeting" then "Reunião"
    when "pedagogical_day" then "Dia Pedagógico"
    when "teacher_training" then "Formação de Professores"
    when "event" then "Evento Especial"
    when "deadline" then "Prazo"
    when "suspension" then "Suspensão das Aulas"
    else calendar_type.humanize
    end
  end
end
