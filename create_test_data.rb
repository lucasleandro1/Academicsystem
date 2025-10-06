# Criando alguns dados de teste para relatórios
puts 'Criando dados de teste...'

escola = School.first
aluno = escola.students.first
disciplina = escola.subjects.first

if aluno && disciplina
  # Criar algumas notas
  3.times do |i|
    Grade.create!(
      user_id: aluno.id,
      subject_id: disciplina.id,
      value: 7.5 + i,
      bimester: 1,
      grade_type: 'prova'
    )
  end

  # Criar algumas faltas
  2.times do |i|
    Absence.create!(
      user_id: aluno.id,
      subject_id: disciplina.id,
      date: Date.current - (i*7).days,
      justified: i.even?
    )
  end

  puts '✅ Dados de teste criados:'
  puts "  - Notas: #{Grade.count}"
  puts "  - Faltas: #{Absence.count}"
  puts "  - Horários: #{ClassSchedule.count}"
else
  puts '❌ Faltam alunos ou disciplinas para criar dados de teste'
end
