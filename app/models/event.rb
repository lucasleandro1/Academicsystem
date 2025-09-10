class Event < ApplicationRecord
  belongs_to :school

  attr_accessor :scope

  def municipal?
    is_municipal == true
  end

  def upcoming?
    return false if event_date.nil?
    event_date >= Date.current
  end

  def formatted_date
    event_date&.strftime("%d/%m/%Y") || "N/A"
  end
end
