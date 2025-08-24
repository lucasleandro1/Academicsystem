module ApplicationHelper
  def calculate_average(enrollment)
    grades = enrollment.grades
    return nil if grades.empty?

    total = grades.sum(:value)
    total.to_f / grades.count
  end

  def get_file_icon(file_type)
    case file_type&.downcase
    when "pdf"
      "pdf"
    when "doc", "docx"
      "word"
    when "xls", "xlsx"
      "excel"
    when "ppt", "pptx"
      "powerpoint"
    when "jpg", "jpeg", "png", "gif"
      "image"
    when "mp4", "avi", "mov"
      "video"
    when "mp3", "wav"
      "audio"
    when "zip", "rar"
      "archive"
    else
      "alt"
    end
  end

  def event_status_color(event)
    if event.end_date && event.end_date < Date.current
      "secondary"  # Evento passado
    elsif event.start_date == Date.current
      "success"    # Evento hoje
    elsif event.start_date > Date.current
      "primary"    # Evento futuro
    else
      "warning"    # Evento em andamento
    end
  end

  def event_status_text(event)
    if event.end_date && event.end_date < Date.current
      "Finalizado"
    elsif event.start_date == Date.current
      "Hoje"
    elsif event.start_date > Date.current
      "Programado"
    else
      "Em andamento"
    end
  end
end
