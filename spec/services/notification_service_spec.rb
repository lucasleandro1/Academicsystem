# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationService, type: :service do
  let(:school) { create(:school) }
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher, school: school) }
  let(:student) { create(:user, :student, school: school) }
  let(:direction) { create(:user, :direction, school: school) }

  describe ".create_system_announcement" do
    let(:title) { "Manutenção do Sistema" }
    let(:content) { "O sistema ficará indisponível das 2h às 4h" }

    context "when no target_users specified" do
      before do
        create_list(:user, 3, active: true)
      end

      it "creates notifications for all active users" do
        expect {
          NotificationService.create_system_announcement(title, content)
        }.to change(Notification, :count).by(User.active.count)
      end

      it "creates notifications with correct attributes" do
        NotificationService.create_system_announcement(title, content)

        notification = Notification.last
        expect(notification.title).to eq(title)
        expect(notification.content).to eq(content)
        expect(notification.notification_type).to eq("system_announcement")
        expect(notification.sender).to eq(User.admins.first)
      end
    end

    context "when target_users specified" do
      let(:target_users) { User.where(id: [ teacher.id, student.id ]) }

      it "creates notifications only for specified users" do
        expect {
          NotificationService.create_system_announcement(title, content, target_users)
        }.to change(Notification, :count).by(2)
      end
    end
  end

  describe ".notify_new_event" do
    let(:event) { create(:event, school: school) }

    context "when event scope is municipal" do
      before { event.update(scope: "municipal") }

      it "notifies all active users" do
        create_list(:user, 2, active: true)

        expect {
          NotificationService.notify_new_event(event)
        }.to change(Notification, :count).by(User.active.count)
      end
    end

    context "when event scope is school" do
      before { event.update(scope: "school") }

      it "notifies only school users" do
        create(:user, :student, school: create(:school))

        expect {
          NotificationService.notify_new_event(event)
        }.to change(Notification, :count).by(school.users.active.count)
      end

      it "creates notification with correct content" do
        NotificationService.notify_new_event(event)

        notification = Notification.last
        expect(notification.title).to include("Novo evento:")
        expect(notification.content).to include(event.description)
        expect(notification.notification_type).to eq("school_event")
        expect(notification.metadata["event_id"]).to eq(event.id)
      end
    end
  end

  describe ".notify_grade_posted" do
    let(:classroom) { create(:classroom, school: school) }
    let(:subject) { create(:subject, school: school, classroom: classroom, teacher: teacher) }
    let(:grade) { create(:grade, subject: subject, student: student) }

    it "creates notification for the student" do
      expect {
        NotificationService.notify_grade_posted(grade)
      }.to change(Notification, :count).by(1)
    end

    it "creates notification with correct attributes" do
      NotificationService.notify_grade_posted(grade)

      notification = Notification.last
      expect(notification.user).to eq(student)
      expect(notification.sender).to eq(teacher)
      expect(notification.school).to eq(school)
      expect(notification.title).to include("Nova nota em")
      expect(notification.content).to include(grade.value.to_s)
      expect(notification.notification_type).to eq("grade_posted")
      expect(notification.metadata["grade_id"]).to eq(grade.id)
      expect(notification.metadata["subject_id"]).to eq(subject.id)
      expect(notification.metadata["grade_value"]).to eq(grade.value)
    end
  end

  describe ".notify_activity_assigned" do
    let(:classroom) { create(:classroom, school: school) }
    let(:subject) { create(:subject, school: school, classroom: classroom, teacher: teacher) }
    let(:activity) { create(:activity, subject: subject, teacher: teacher, school: school) }

    before do
      create_list(:user, 2, :student, classroom: classroom, active: true)
    end

    it "creates notifications for all active students in the classroom" do
      expect {
        NotificationService.notify_activity_assigned(activity)
      }.to change(Notification, :count).by(2)
    end

    it "creates notification with correct attributes" do
      NotificationService.notify_activity_assigned(activity)

      notification = Notification.last
      expect(notification.sender).to eq(teacher)
      expect(notification.school).to eq(school)
      expect(notification.title).to include("Nova atividade:")
      expect(notification.content).to include(activity.description)
      expect(notification.notification_type).to eq("activity_assigned")
      expect(notification.metadata["activity_id"]).to eq(activity.id)
      expect(notification.metadata["subject_id"]).to eq(subject.id)
    end
  end

  describe ".notify_document_available" do
    let(:document) { create(:document, school: school) }
    let(:recipients) { User.where(id: [ teacher.id, student.id ]) }

    it "creates notifications for all recipients" do
      expect {
        NotificationService.notify_document_available(document, recipients)
      }.to change(Notification, :count).by(2)
    end

    it "creates notification with correct attributes" do
      NotificationService.notify_document_available(document, recipients)

      notification = Notification.last
      expect(notification.school).to eq(school)
      expect(notification.title).to eq("Novo documento disponível")
      expect(notification.content).to include(document.title)
      expect(notification.content).to include(document.document_type)
      expect(notification.notification_type).to eq("document_available")
      expect(notification.metadata["document_id"]).to eq(document.id)
    end
  end

  describe ".notify_attendance_alert" do
    let(:absences_count) { 12 }

    context "when absences count meets threshold" do
      it "creates notification for the student" do
        expect {
          NotificationService.notify_attendance_alert(student, absences_count)
        }.to change(Notification, :count).by(2) # student + direction
      end

      it "creates notification with correct content for student" do
        NotificationService.notify_attendance_alert(student, absences_count)

        student_notification = Notification.where(user: student).last
        expect(student_notification.title).to eq("Alerta de frequência")
        expect(student_notification.content).to include(absences_count.to_s)
        expect(student_notification.notification_type).to eq("attendance_alert")
        expect(student_notification.metadata["absences_count"]).to eq(absences_count)
      end

      it "creates notification for direction" do
        NotificationService.notify_attendance_alert(student, absences_count)

        direction_notification = Notification.where(user: direction).last
        expect(direction_notification.title).to include("Alerta de frequência")
        expect(direction_notification.content).to include(student.full_name)
        expect(direction_notification.metadata["student_id"]).to eq(student.id)
      end
    end

    context "when absences count is below threshold" do
      let(:absences_count) { 5 }

      it "does not create notifications" do
        expect {
          NotificationService.notify_attendance_alert(student, absences_count)
        }.not_to change(Notification, :count)
      end
    end
  end

  describe ".notify_message_received" do
    let(:message) { double("Message", recipient: student, sender: teacher, school: school, subject: "Test Subject", id: 1) }

    it "creates notification for the recipient" do
      expect(Notification).to receive(:create!).with(
        user: student,
        sender: teacher,
        school: school,
        title: "Nova mensagem recebida",
        content: "Você recebeu uma nova mensagem de #{teacher.full_name}\nAssunto: Test Subject",
        notification_type: "message_received",
        metadata: { message_id: 1 }
      )

      NotificationService.notify_message_received(message)
    end
  end

  describe ".notify_calendar_update" do
    let(:calendar_event) { double("CalendarEvent", id: 1) }
    let(:users) { User.where(id: [ teacher.id, student.id ]) }

    it "creates notifications for all specified users" do
      expect {
        NotificationService.notify_calendar_update(calendar_event, users)
      }.to change(Notification, :count).by(2)
    end

    it "creates notification with correct attributes" do
      NotificationService.notify_calendar_update(calendar_event, users)

      notification = Notification.last
      expect(notification.title).to eq("Atualização no calendário")
      expect(notification.content).to include("calendário acadêmico foi atualizado")
      expect(notification.notification_type).to eq("calendar_update")
      expect(notification.metadata["calendar_event_id"]).to eq(1)
    end
  end

  describe ".notify_system_maintenance" do
    let(:title) { "Manutenção programada" }
    let(:content) { "Sistema será atualizado" }
    let(:scheduled_time) { 1.day.from_now }

    before do
      create_list(:user, 2, active: true)
    end

    it "creates notifications for all active users" do
      expect {
        NotificationService.notify_system_maintenance(title, content, scheduled_time)
      }.to change(Notification, :count).by(User.active.count)
    end

    it "creates notification with correct attributes" do
      NotificationService.notify_system_maintenance(title, content, scheduled_time)

      notification = Notification.last
      expect(notification.title).to eq(title)
      expect(notification.content).to eq(content)
      expect(notification.notification_type).to eq("system_maintenance")
      expect(notification.metadata["scheduled_time"]).to eq(scheduled_time)
    end
  end
end
