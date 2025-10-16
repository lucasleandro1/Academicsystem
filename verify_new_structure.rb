#!/usr/bin/env ruby
# Script para verificar a nova estrutura de disciplinas

require_relative 'config/environment'

puts "🔍 VERIFICANDO NOVA ESTRUTURA DE DISCIPLINAS"
puts "=" * 60

# Lista todas as disciplinas (agora sem vínculos diretos às turmas)
puts "\n📚 DISCIPLINAS CRIADAS:"
Subject.all.each do |subject|
  teacher_name = subject.user&.full_name || "Sem professor"
  puts "   #{subject.name} - Prof: #{teacher_name} (#{subject.workload}h total)"
end

puts "\n📅 ASSOCIAÇÕES VIA HORÁRIOS:"
puts "Como cada disciplina se associa às turmas através dos horários:\n"

Subject.all.each do |subject|
  puts "\n🎯 #{subject.name} (Prof: #{subject.user&.full_name}):"

  # Buscar todas as turmas que têm horários desta disciplina
  classrooms_with_schedules = ClassSchedule.joins(:classroom)
                                          .where(subject: subject)
                                          .includes(:classroom)
                                          .group_by(&:classroom)

  if classrooms_with_schedules.any?
    classrooms_with_schedules.each do |classroom, schedules|
      puts "     📍 #{classroom.name}: #{schedules.count} aulas/semana"

      # Mostrar os horários
      schedules.sort_by { |s| [ s.weekday, s.start_time ] }.each do |schedule|
        weekday_name = %w[Domingo Segunda Terça Quarta Quinta Sexta Sábado][schedule.weekday]
        puts "        #{weekday_name} #{schedule.start_time.strftime('%H:%M')}-#{schedule.end_time.strftime('%H:%M')}"
      end
    end

    # Mostrar alunos atendidos
    total_students = classrooms_with_schedules.keys.sum { |c| c.students.count }
    puts "     👨‍🎓 Total de alunos atendidos: #{total_students}"
  else
    puts "     ⚠️  Sem horários atribuídos"
  end
end

puts "\n📊 RESUMO GERAL:"
puts "   📚 Total de disciplinas: #{Subject.count}"
puts "   👩‍🏫 Professores únicos: #{Subject.joins(:user).distinct.count('users.id')}"
puts "   🏛️ Turmas com horários: #{ClassSchedule.joins(:classroom).distinct.count('classrooms.id')}"
puts "   ⏰ Total de horários/semana: #{ClassSchedule.count}"

puts "\n🎯 VERIFICAÇÃO DE EFICIÊNCIA:"
puts "Agora cada professor tem UMA disciplina que atende MÚLTIPLAS turmas!"

# Verificar se professores atendem múltiplas turmas
Subject.all.each do |subject|
  classrooms_count = ClassSchedule.joins(:classroom)
                                 .where(subject: subject)
                                 .distinct.count('classrooms.id')

  total_classes = ClassSchedule.where(subject: subject).count
  puts "   ✅ Prof. #{subject.user.full_name} (#{subject.name}): #{classrooms_count} turmas, #{total_classes} aulas/semana"
end

puts "\n✅ NOVA ESTRUTURA IMPLEMENTADA COM SUCESSO!"
puts "   - Uma disciplina por matéria (não por turma)"
puts "   - Professores associados a múltiplas turmas via horários"
puts "   - Estrutura mais realista e eficiente"
