class Event < ApplicationRecord
  belongs_to :school

  attr_accessor :scope

  def municipal?
    is_municipal == true
  end

  def upcoming?
    return false if start_date.nil?
    start_date >= Date.current
  end

  def status
    return "completed" if end_date && end_date < Date.current
    return "ongoing" if start_date && end_date && start_date <= Date.current && end_date >= Date.current
    return "planned" if start_date && start_date > Date.current
    "planned"
  end

  def formatted_date
    start_date&.strftime("%d/%m/%Y") || "N/A"
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

  def formatted_created_at
    created_at&.strftime("%d/%m/%Y às %H:%M") || "Data não disponível"
  end

  def formatted_updated_at
    updated_at&.strftime("%d/%m/%Y às %H:%M") || "Data não disponível"
  end
end
