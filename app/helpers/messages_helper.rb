module MessagesHelper
  def recipient_options_grouped(current_user)
    service = MessageRecipientService.new(current_user)
    recipients_grouped = service.available_recipients_grouped

    grouped_options = []
    recipients_grouped.each do |group_name, users|
      next if users.empty?

      # As relações já estão pré-carregadas no service
      options = users.map { |user| [ format_user_display_name(user), user.id ] }
      grouped_options << [ group_name, options ]
    end

    grouped_options
  end

  def broadcast_options(current_user)
    service = MessageRecipientService.new(current_user)
    service.broadcast_options
  end

  def schools_for_broadcast_select(current_user)
    service = MessageRecipientService.new(current_user)
    schools = service.schools_for_broadcast
    options_from_collection_for_select(schools, :id, :name)
  end

  def classrooms_for_broadcast_select(current_user)
    service = MessageRecipientService.new(current_user)
    classrooms = service.classrooms_for_broadcast
    options_from_collection_for_select(classrooms, :id, :display_name)
  end

  def format_user_display_name(user)
    case user.user_type
    when "direction"
      "#{user.full_name} (Direção)"
    when "teacher"
      "#{user.full_name} (Professor)"
    when "student"
      # Como as classrooms já estão pré-carregadas, podemos acessar diretamente
      classroom_info = user.classroom&.name ? " - #{user.classroom.name}" : ""
      "#{user.full_name} (Aluno#{classroom_info})"
    else
      user.full_name
    end
  end

  def message_recipient_badge_class(user)
    case user.user_type
    when "direction"
      "badge bg-primary"
    when "teacher"
      "badge bg-success"
    when "student"
      "badge bg-info"
    when "admin"
      "badge bg-warning"
    else
      "badge bg-secondary"
    end
  end

  def message_recipient_icon(user)
    case user.user_type
    when "direction"
      "fas fa-user-tie"
    when "teacher"
      "fas fa-chalkboard-teacher"
    when "student"
      "fas fa-user-graduate"
    when "admin"
      "fas fa-user-shield"
    else
      "fas fa-user"
    end
  end

  def can_send_to_recipient?(current_user, recipient_id)
    service = MessageRecipientService.new(current_user)
    service.can_send_to?(recipient_id)
  end
end
