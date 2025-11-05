# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Debug Messages", type: :model do
  let(:school) { create(:school) }
  let(:classroom) { create(:classroom, school: school) }
  let(:teacher) { create(:user, :teacher, school: school) }
  let(:student) { create(:user, :student, school: school, classroom: classroom) }

  it "debugs the teacher-student relationship" do
    # Criar disciplina
    subject = create(:subject, user: teacher, classroom: classroom, school: school)
    
    puts "=== DEBUG INFO ==="
    puts "School ID: #{school.id}"
    puts "Classroom ID: #{classroom.id}"
    puts "Teacher ID: #{teacher.id}, School: #{teacher.school_id}"
    puts "Student ID: #{student.id}, School: #{student.school_id}, Classroom: #{student.classroom_id}"
    puts "Subject ID: #{subject.id}, User: #{subject.user_id}, Classroom: #{subject.classroom_id}"
    
    # Testar consultas
    puts "\n=== STUDENT QUERIES ==="
    puts "Student classroom: #{student.classroom&.id}"
    puts "Student classroom subjects: #{student.classroom&.subjects&.pluck(:id)}"
    puts "Student classroom subjects user_ids: #{student.classroom&.subjects&.pluck(:user_id)}"
    
    teacher_ids = student.classroom.subjects.pluck(:user_id)
    direction_ids = student.school.directions.pluck(:id)
    recipients = User.where(id: teacher_ids + direction_ids)
    
    puts "Teacher IDs: #{teacher_ids}"
    puts "Direction IDs: #{direction_ids}"
    puts "Recipients: #{recipients.pluck(:id)}"
    puts "Teacher included? #{recipients.include?(teacher)}"
    
    # Testar criação de mensagem
    puts "\n=== MESSAGE VALIDATION ==="
    message = build(:message, sender: student, recipient: teacher, school: student.school)
    puts "Message valid? #{message.valid?}"
    puts "Message errors: #{message.errors.full_messages}" unless message.valid?
  end
end