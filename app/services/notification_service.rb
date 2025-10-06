class NotificationService
  def self.create_system_announcement(title, content, target_users = nil)
    target_users ||= User.active

    target_users.find_each do |user|
      Notification.create!(
        user: user,
        sender: User.admins.first,
        title: title,
        content: content,
        notification_type: "system_announcement"
      )
    end
  end

  def self.notify_new_event(event)
    case event.scope
    when "municipal"
      # Notificar todos os usuários
      target_users = User.active
    when "school"
      # Notificar apenas usuários da escola
      target_users = event.school.users.active
    else
      target_users = User.none
    end

    target_users.find_each do |user|
      Notification.create!(
        user: user,
        sender: event.school&.directions&.first || User.admins.first,
        school: event.school,
        title: "Novo evento: #{event.title}",
        content: "#{event.description}\nData: #{event.start_date&.strftime('%d/%m/%Y')}",
        notification_type: "school_event",
        metadata: { event_id: event.id }
      )
    end
  end

  def self.notify_grade_posted(grade)
    Notification.create!(
      user: grade.student,
      sender: grade.subject.teacher,
      school: grade.student.school,
      title: "Nova nota em #{grade.subject.name}",
      content: "Sua nota foi lançada: #{grade.value}\nData: #{grade.created_at.strftime('%d/%m/%Y')}",
      notification_type: "grade_posted",
      metadata: {
        grade_id: grade.id,
        subject_id: grade.subject.id,
        grade_value: grade.value
      }
    )
  end

  def self.notify_document_available(document, recipients)
    recipients.find_each do |user|
      Notification.create!(
        user: user,
        sender: document.uploader || User.admins.first,
        school: document.school,
        title: "Novo documento disponível",
        content: "Um novo documento foi disponibilizado: #{document.title}\nTipo: #{document.document_type}",
        notification_type: "document_available",
        metadata: { document_id: document.id }
      )
    end
  end

  def self.notify_attendance_alert(student, absences_count)
    # Notificar quando aluno tem muitas faltas
    threshold = 10 # número de faltas para alertar

    if absences_count >= threshold
      Notification.create!(
        user: student,
        sender: student.school.directions.first || User.admins.first,
        school: student.school,
        title: "Alerta de frequência",
        content: "Você possui #{absences_count} faltas registradas. Atenção para não ultrapassar o limite permitido.",
        notification_type: "attendance_alert",
        metadata: { absences_count: absences_count }
      )

      # Notificar também a direção
      student.school.directions.each do |director|
        Notification.create!(
          user: director,
          sender: User.admins.first,
          school: student.school,
          title: "Alerta de frequência - #{student.full_name}",
          content: "O aluno #{student.full_name} possui #{absences_count} faltas registradas.",
          notification_type: "attendance_alert",
          metadata: { student_id: student.id, absences_count: absences_count }
        )
      end
    end
  end

  def self.notify_message_received(message)
    Notification.create!(
      user: message.recipient,
      sender: message.sender,
      school: message.school,
      title: "Nova mensagem recebida",
      content: "Você recebeu uma nova mensagem de #{message.sender.full_name}\nAssunto: #{message.subject}",
      notification_type: "message_received",
      metadata: { message_id: message.id }
    )
  end

  def self.notify_calendar_update(calendar_event, users)
    users.find_each do |user|
      Notification.create!(
        user: user,
        sender: User.admins.first,
        title: "Atualização no calendário",
        content: "O calendário acadêmico foi atualizado. Verifique as novas datas e eventos.",
        notification_type: "calendar_update",
        metadata: { calendar_event_id: calendar_event&.id }
      )
    end
  end

  def self.notify_system_maintenance(title, content, scheduled_time = nil)
    User.active.find_each do |user|
      Notification.create!(
        user: user,
        sender: User.admins.first,
        title: title,
        content: content,
        notification_type: "system_maintenance",
        metadata: { scheduled_time: scheduled_time }
      )
    end
  end
end
