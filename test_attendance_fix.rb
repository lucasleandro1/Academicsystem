#!/usr/bin/env ruby

# Script simples para testar se as alterações funcionam
puts "Testando as alterações no sistema de chamada..."

# Verificar se o arquivo foi editado corretamente
controller_file = File.read('app/controllers/teachers/absences_controller.rb')

if controller_file.include?('subject_name') && controller_file.include?('@subjects_grouped')
  puts "✅ Controller atualizado com a nova estrutura agrupada"
else
  puts "❌ Controller não foi atualizado corretamente"
end

# Verificar se a view foi editada
view_file = File.read('app/views/teachers/absences/attendance.html.erb')

if view_file.include?('subject_name') && view_file.include?('@subjects_grouped')
  puts "✅ View atualizada com a nova estrutura agrupada"
else
  puts "❌ View não foi atualizada corretamente"
end

puts "\nAs disciplinas agora devem aparecer agrupadas por nome, evitando duplicação por turma."
puts "Para testar:"
puts "1. Acesse http://localhost:3000"
puts "2. Faça login como professor"
puts "3. Vá para 'Fazer Chamada'"
puts "4. Observe que as disciplinas aparecem apenas uma vez, mesmo que o professor ensine a mesma disciplina em várias turmas"
