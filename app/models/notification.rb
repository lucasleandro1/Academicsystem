class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: "User"
  belongs_to :school, optional: true

  validates :title, :content, :notification_type, presence: true
  validates :notification_type, inclusion: { in: %w[
    system_announcement
    school_event
    grade_posted
    activity_assigned
    message_received
    attendance_alert
    enrollment_status
    document_available
    calendar_update
    system_maintenance
  ] }

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :for_school, ->(school) { where(school: school) }

  def mark_as_read!
    update(read: true, read_at: Time.current) unless read?
  end

  def read?
    read
  end

  def type_icon
    case notification_type
    when "system_announcement"
      "fas fa-bullhorn"
    when "school_event"
      "fas fa-calendar-alt"
    when "grade_posted"
      "fas fa-chart-line"
    when "activity_assigned"
      "fas fa-tasks"
    when "message_received"
      "fas fa-envelope"
    when "attendance_alert"
      "fas fa-exclamation-triangle"
    when "enrollment_status"
      "fas fa-user-check"
    when "document_available"
      "fas fa-file-alt"
    when "calendar_update"
      "fas fa-calendar-check"
    when "system_maintenance"
      "fas fa-tools"
    else
      "fas fa-bell"
    end
  end

  def type_color
    case notification_type
    when "system_announcement"
      "primary"
    when "school_event"
      "info"
    when "grade_posted"
      "success"
    when "activity_assigned"
      "warning"
    when "message_received"
      "primary"
    when "attendance_alert"
      "danger"
    when "enrollment_status"
      "success"
    when "document_available"
      "info"
    when "calendar_update"
      "secondary"
    when "system_maintenance"
      "warning"
    else
      "secondary"
    end
  end

  # Métodos de classe para criar notificações específicas
  def self.create_system_announcement(title, content, recipient_users = nil)
    recipient_users ||= User.active
    recipient_users.find_each do |user|
      create!(
        user: user,
        sender: User.admins.first,
        title: title,
        content: content,
        notification_type: "system_announcement"
      )
    end
  end

  def self.create_school_event_notification(event, users)
    users.find_each do |user|
      create!(
        user: user,
        sender: event.school.directions.first || User.admins.first,
        school: event.school,
        title: "Novo evento: #{event.title}",
        content: "#{event.description}\nData: #{event.start_date&.strftime('%d/%m/%Y')}",
        notification_type: "school_event",
        metadata: { event_id: event.id }
      )
    end
  end

  def self.create_grade_notification(grade)
    create!(
      user: grade.student,
      sender: grade.subject.teacher,
      school: grade.student.school,
      title: "Nova nota lançada",
      content: "Sua nota em #{grade.subject.name} foi lançada: #{grade.value}",
      notification_type: "grade_posted",
      metadata: { grade_id: grade.id, subject_id: grade.subject.id }
    )
  end

  def self.create_activity_notification(activity)
    students = activity.subject.classroom.students
    students.find_each do |student|
      create!(
        user: student,
        sender: activity.teacher,
        school: activity.school,
        title: "Nova atividade: #{activity.title}",
        content: "#{activity.description}\nPrazo: #{activity.due_date&.strftime('%d/%m/%Y')}",
        notification_type: "activity_assigned",
        metadata: { activity_id: activity.id, subject_id: activity.subject.id }
      )
    end
  end
end
