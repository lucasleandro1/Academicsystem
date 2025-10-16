#!/usr/bin/env ruby

# Add Rails environment
require File.expand_path('../config/environment', __FILE__)

puts "=== VERIFICAÇÃO DE DISCIPLINAS ==="
puts "Total de disciplinas: #{Subject.count}"
puts "Disciplinas sem classroom específica (compartilhadas): #{Subject.where(classroom_id: nil).count}"
puts "Disciplinas com classroom específica: #{Subject.where.not(classroom_id: nil).count}"

puts "\n=== LISTA DE DISCIPLINAS ==="
Subject.all.each do |subject|
  classroom_info = subject.classroom_id ? "Turma #{subject.classroom_id}" : "Compartilhada"
  puts "- #{subject.name} (#{subject.code}) - #{classroom_info}"
end

puts "\n=== DISCIPLINA ARTES - VERIFICAÇÃO DETALHADA ==="
artes = Subject.find_by(name: 'Artes')
if artes
  puts "Nome: #{artes.name}"
  puts "Código: #{artes.code}"
  puts "Classroom ID: #{artes.classroom_id || 'nil (compartilhada)'}"
  puts "Professor: #{artes.user&.full_name}"
  puts "Número de horários: #{artes.class_schedules.count}"
  puts "Turmas atendidas através de horários:"
  artes.class_schedules.includes(:classroom).each do |schedule|
    puts "  - #{schedule.classroom.name} (#{schedule.weekday_name} às #{schedule.start_time.strftime('%H:%M')})"
  end
  puts "Total de alunos: #{artes.students.count}"
else
  puts "Disciplina Artes não encontrada!"
end

puts "\n=== VERIFICAÇÃO DE HORÁRIOS POR DISCIPLINA ==="
Subject.all.each do |subject|
  schedules_count = subject.class_schedules.count
  classrooms_count = subject.class_schedules.joins(:classroom).distinct.count('classrooms.id')
  puts "#{subject.name}: #{schedules_count} horários, #{classrooms_count} turmas diferentes"
end
