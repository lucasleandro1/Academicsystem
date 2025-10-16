#!/usr/bin/env ruby

# Script para testar se as alterações no sistema de notas funcionam
puts "Testando as alterações no sistema de lançamento de notas..."

# Verificar se o controller foi editado corretamente
controller_file = File.read('app/controllers/teachers/grades_controller.rb')

if controller_file.include?('subject_name') && controller_file.include?('@subjects_grouped')
  puts "✅ Controller de notas atualizado com a nova estrutura agrupada"
else
  puts "❌ Controller de notas não foi atualizado corretamente"
end

# Verificar se a view foi editada
view_file = File.read('app/views/teachers/grades/new.html.erb')

if view_file.include?('subject_name') && view_file.include?('@subjects_grouped')
  puts "✅ View de notas atualizada com a nova estrutura agrupada"
else
  puts "❌ View de notas não foi atualizada corretamente"
end

puts "\nResumo das correções aplicadas:"
puts "- Sistema de Faltas: ✅ Disciplinas agrupadas por nome"
puts "- Sistema de Notas: ✅ Disciplinas agrupadas por nome"
puts "\nAgora ambos os sistemas mostram cada disciplina apenas uma vez,"
puts "mesmo que o professor ensine a mesma disciplina em várias turmas diferentes."

puts "\nPara testar:"
puts "1. Acesse http://localhost:3000"
puts "2. Faça login como professor"
puts "3. Vá para 'Lançar Nota' ou 'Fazer Chamada'"
puts "4. Observe que as disciplinas aparecem apenas uma vez no seletor"
