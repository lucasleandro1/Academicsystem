#!/usr/bin/env ruby
# Script to verify seed data

require_relative 'config/environment'

puts "🔍 VERIFICANDO DADOS DO SEED"
puts "=" * 50

# School verification
school = School.first
puts "\n🏫 ESCOLA:"
puts "   Nome: #{school.name}"
puts "   CNPJ: #{school.cnpj}"
puts "   Endereço: #{school.address}"
puts "   Telefone: #{school.phone}"
puts "   Email: #{school.email}"

# Users verification
puts "\n👥 USUÁRIOS:"
puts "   Admin: #{User.where(user_type: 'admin').count}"
puts "   Direção: #{User.where(user_type: 'direction').count}"
puts "   Professores: #{User.where(user_type: 'teacher').count}"
puts "   Alunos: #{User.where(user_type: 'student').count}"
puts "   Total: #{User.count}"

# Classrooms verification
puts "\n🏛️ TURMAS:"
Classroom.all.each do |classroom|
  student_count = classroom.students.count
  subject_count = classroom.subjects.count
  puts "   #{classroom.name} (#{classroom.shift}) - #{student_count} alunos, #{subject_count} disciplinas"
end

# Subjects verification
puts "\n📚 DISCIPLINAS POR TURMA:"
Classroom.all.each do |classroom|
  puts "   #{classroom.name}:"
  classroom.subjects.each do |subject|
    teacher_name = subject.user&.full_name || "Sem professor"
    puts "     - #{subject.name} (#{subject.workload}h) - Prof: #{teacher_name}"
  end
end

# Class schedules verification
puts "\n📅 HORÁRIOS DE AULA:"
total_schedules = ClassSchedule.count
puts "   Total de horários criados: #{total_schedules}"
puts "   Distribuição por turma:"
Classroom.all.each do |classroom|
  schedules_count = classroom.class_schedules.count
  puts "     #{classroom.name}: #{schedules_count} horários"
end

# Grades verification
puts "\n📊 NOTAS (3º BIMESTRE):"
total_grades = Grade.count
puts "   Total de notas: #{total_grades}"
puts "   Média geral: #{Grade.average(:value)&.round(2)}"
puts "   Distribuição por tipo:"
Grade.group(:grade_type).count.each do |type, count|
  puts "     #{type.humanize}: #{count}"
end

# Absences verification
puts "\n❌ FALTAS:"
total_absences = Absence.count
justified_count = Absence.where(justified: true).count
puts "   Total de faltas: #{total_absences}"
puts "   Justificadas: #{justified_count}"
puts "   Não justificadas: #{total_absences - justified_count}"

# Documents verification
puts "\n📄 DOCUMENTOS:"
total_documents = Document.count
puts "   Total de documentos: #{total_documents}"
puts "   Distribuição por tipo:"
Document.group(:document_type).count.each do |type, count|
  puts "     #{type.humanize}: #{count}"
end

# Events verification
puts "\n🎉 EVENTOS:"
total_events = Event.count
puts "   Total de eventos: #{total_events}"
puts "   Próximos eventos:"
Event.upcoming.limit(3).each do |event|
  puts "     - #{event.title} (#{event.formatted_start_date})"
end

# Messages verification
puts "\n💬 MENSAGENS:"
total_messages = Message.count
unread_count = Message.where(read_at: nil).count
puts "   Total de mensagens: #{total_messages}"
puts "   Não lidas: #{unread_count}"

puts "\n✅ VERIFICAÇÃO CONCLUÍDA!"
puts "\nℹ️  CREDENCIAIS DE ACESSO:"
puts "   Admin: admin@sistema.com / 123456"
puts "   Diretor: diretor@dompedroii.edu.br / diretor123"
puts "   Coordenador: coordenacao@dompedroii.edu.br / coord123"
puts "   Professores: [nome].@dompedroii.edu.br / professor123"
puts "   Alunos: [nome].[sobrenome]@aluno.dompedroii.edu.br / aluno123"
