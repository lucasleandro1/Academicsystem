#!/usr/bin/env ruby

# Script para verificar funcionalidades do módulo de direção

require File.expand_path('config/environment', __dir__)

puts "=== VERIFICAÇÃO DO MÓDULO DIREÇÃO ==="
puts

# 1. Verificar usuários diretor
directors = User.where(user_type: 'direction')
puts "📋 DIRETORES CADASTRADOS: #{directors.count}"
directors.each do |director|
  school_name = director.school&.name || "SEM ESCOLA"
  puts "  - #{director.email} (Escola: #{school_name})"
end
puts

# 2. Verificar escolas e dados básicos
puts "🏫 ESCOLAS E ESTATÍSTICAS:"
School.all.each do |school|
  students_count = User.where(school_id: school.id, user_type: 'student').count
  teachers_count = User.where(school_id: school.id, user_type: 'teacher').count
  classrooms_count = school.classrooms.count

  puts "  Escola: #{school.name}"
  puts "    - Alunos: #{students_count}"
  puts "    - Professores: #{teachers_count}"
  puts "    - Turmas: #{classrooms_count}"
  puts
end

# 3. Verificar turmas e disciplinas
puts "🎓 TURMAS E DISCIPLINAS:"
Classroom.all.each do |classroom|
  subjects_count = classroom.subjects.count
  students_count = classroom.students.count

  puts "  Turma: #{classroom.name} (#{classroom.school.name})"
  puts "    - Alunos: #{students_count}"
  puts "    - Disciplinas: #{subjects_count}"

  classroom.subjects.each do |subject|
    teacher_name = subject.teacher&.full_name || "SEM PROFESSOR"
    puts "      * #{subject.name} - Professor: #{teacher_name}"
  end
  puts
end

# 4. Verificar eventos
puts "📅 EVENTOS:"
events_count = Event.count
puts "  Total de eventos: #{events_count}"
Event.limit(5).each do |event|
  puts "  - #{event.title} (#{event.start_date&.strftime('%d/%m/%Y')})"
end
puts

# 5. Verificar mensagens
puts "💬 MENSAGENS:"
messages_count = Message.count
puts "  Total de mensagens: #{messages_count}"
puts

# 6. Verificar horários de aula
puts "⏰ HORÁRIOS DE AULA:"
schedules_count = ClassSchedule.count
puts "  Total de horários: #{schedules_count}"
ClassSchedule.all.each do |schedule|
  classroom_name = schedule.classroom&.name || "TURMA INDEFINIDA"
  subject_name = schedule.subject&.name || "DISCIPLINA INDEFINIDA"
  day_name = schedule.weekday_name

  puts "  - #{classroom_name}: #{subject_name} (#{day_name} #{schedule.start_time&.strftime('%H:%M')}-#{schedule.end_time&.strftime('%H:%M')})"
end
puts

# 7. Verificar documentos
puts "📄 DOCUMENTOS:"
documents_count = Document.count
puts "  Total de documentos: #{documents_count}"
puts

# 8. Verificar integridade dos dados
puts "⚠️  VERIFICAÇÕES DE INTEGRIDADE:"

# Professores sem escola
teachers_without_school = User.where(user_type: 'teacher', school_id: nil).count
puts "  - Professores sem escola: #{teachers_without_school}"

# Alunos sem turma
students_without_classroom = User.where(user_type: 'student', classroom_id: nil).count
puts "  - Alunos sem turma: #{students_without_classroom}"

# Disciplinas sem professor
subjects_without_teacher = Subject.where(user_id: nil).count
puts "  - Disciplinas sem professor: #{subjects_without_teacher}"

# Turmas sem disciplinas
classrooms_without_subjects = Classroom.left_joins(:subjects).where(subjects: { id: nil }).count
puts "  - Turmas sem disciplinas: #{classrooms_without_subjects}"

puts
puts "=== VERIFICAÇÃO CONCLUÍDA ==="
