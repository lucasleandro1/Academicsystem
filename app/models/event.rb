class Event < ApplicationRecord
  belongs_to :school

  def municipal?
    is_municipal == true
  end

  def upcoming?
    event_date && event_date >= Date.current
  end

  def formatted_date
    event_date&.strftime("%d/%m/%Y") || "N/A"
  end
end
