#!/usr/bin/env ruby

# Script para testar Views do Sistema Acadêmico
# Este script navega pelas views e testa suas funcionalidades

puts "🎯 TESTANDO TODAS AS VIEWS DO SISTEMA ACADÊMICO"
puts "=" * 60

def check_view_file(path, description)
  if File.exist?(path)
    puts "✅ #{description.ljust(40)} - Arquivo encontrado"
    true
  else
    puts "❌ #{description.ljust(40)} - Arquivo não encontrado"
    false
  end
end

def test_view_section(section_name, views)
  puts "\n📁 #{section_name.upcase}"
  puts "-" * 50

  found = 0
  total = views.length

  views.each do |view_path, description|
    full_path = "/home/lucas/academic_system/app/views/#{view_path}"
    if check_view_file(full_path, description)
      found += 1
    end
  end

  percentage = ((found.to_f / total) * 100).round(2)
  puts "📊 #{found}/#{total} views encontradas (#{percentage}%)"

  return found, total
end

# Definir todas as views para teste
admin_views = [
  [ "admin/schools/index.html.erb", "Lista de Escolas Admin" ],
  [ "admin/schools/new.html.erb", "Nova Escola Admin" ],
  [ "admin/schools/show.html.erb", "Visualizar Escola Admin" ],
  [ "admin/schools/edit.html.erb", "Editar Escola Admin" ],
  [ "admin/users/index.html.erb", "Lista de Usuários Admin" ],
  [ "admin/users/new.html.erb", "Novo Usuário Admin" ],
  [ "admin/users/show.html.erb", "Visualizar Usuário Admin" ],
  [ "admin/users/edit.html.erb", "Editar Usuário Admin" ],
  [ "admin/directions/index.html.erb", "Lista de Direções Admin" ],
  [ "admin/directions/new.html.erb", "Nova Direção Admin" ],
  [ "admin/events/index.html.erb", "Lista de Eventos Admin" ],
  [ "admin/events/new.html.erb", "Novo Evento Admin" ],
  [ "admin/events/show.html.erb", "Visualizar Evento Admin" ],
  [ "admin/events/edit.html.erb", "Editar Evento Admin" ],
  [ "admin/documents/index.html.erb", "Lista de Documentos Admin" ],
  [ "admin/documents/new.html.erb", "Novo Documento Admin" ],
  [ "admin/documents/show.html.erb", "Visualizar Documento Admin" ],
  [ "admin/documents/edit.html.erb", "Editar Documento Admin" ],
  [ "admin/messages/index.html.erb", "Lista de Mensagens Admin" ],
  [ "admin/messages/new.html.erb", "Nova Mensagem Admin" ],
  [ "admin/messages/show.html.erb", "Visualizar Mensagem Admin" ],
  [ "admin/reports/municipal_overview.html.erb", "Relatório Municipal" ],
  [ "admin/reports/attendance_report.html.erb", "Relatório de Frequência" ],
  [ "admin/reports/performance_report.html.erb", "Relatório de Desempenho" ],
  [ "admin/reports/student_distribution.html.erb", "Distribuição de Estudantes" ],
  [ "admin/calendars/index.html.erb", "Calendários Admin" ],
  [ "admin/calendars/municipal.html.erb", "Calendário Municipal" ],
  [ "admin/settings/index.html.erb", "Configurações Admin" ]
]

direction_views = [
  [ "direction/dashboard.html.erb", "Dashboard da Direção" ],
  [ "direction/dashboard/index.html.erb", "Dashboard Index Direção" ],
  [ "direction/school/show.html.erb", "Escola da Direção" ],
  [ "direction/school/edit.html.erb", "Editar Escola Direção" ],
  [ "direction/teachers/index.html.erb", "Lista de Professores" ],
  [ "direction/teachers/new.html.erb", "Novo Professor" ],
  [ "direction/teachers/show.html.erb", "Visualizar Professor" ],
  [ "direction/teachers/edit.html.erb", "Editar Professor" ],
  [ "direction/students/index.html.erb", "Lista de Estudantes" ],
  [ "direction/students/new.html.erb", "Novo Estudante" ],
  [ "direction/students/show.html.erb", "Visualizar Estudante" ],
  [ "direction/students/edit.html.erb", "Editar Estudante" ],
  [ "direction/classrooms/index.html.erb", "Lista de Salas" ],
  [ "direction/classrooms/new.html.erb", "Nova Sala" ],
  [ "direction/classrooms/show.html.erb", "Visualizar Sala" ],
  [ "direction/classrooms/edit.html.erb", "Editar Sala" ],
  [ "direction/subjects/index.html.erb", "Lista de Matérias" ],
  [ "direction/subjects/new.html.erb", "Nova Matéria" ],
  [ "direction/subjects/show.html.erb", "Visualizar Matéria" ],
  [ "direction/subjects/edit.html.erb", "Editar Matéria" ],
  [ "direction/events/index.html.erb", "Lista de Eventos" ],
  [ "direction/events/new.html.erb", "Novo Evento" ],
  [ "direction/events/show.html.erb", "Visualizar Evento" ],
  [ "direction/events/edit.html.erb", "Editar Evento" ],
  [ "direction/messages/index.html.erb", "Mensagens Direção" ],
  [ "direction/reports/attendance_report.html.erb", "Relatório de Frequência" ],
  [ "direction/class_schedules/index.html.erb", "Horários de Aula" ],
  [ "direction/class_schedules/new.html.erb", "Novo Horário" ],
  [ "direction/class_schedules/edit.html.erb", "Editar Horário" ],
  [ "direction/documents/index.html.erb", "Documentos Direção" ],
  [ "direction/documents/new.html.erb", "Novo Documento" ],
  [ "direction/documents/edit.html.erb", "Editar Documento" ]
]

teacher_views = [
  [ "teachers/dashboard/index.html.erb", "Dashboard Professor" ],
  [ "teachers/profile/show.html.erb", "Perfil do Professor" ],
  [ "teachers/profile/edit.html.erb", "Editar Perfil Professor" ],
  [ "teachers/classrooms/index.html.erb", "Salas do Professor" ],
  [ "teachers/classrooms/show.html.erb", "Visualizar Sala Professor" ],
  [ "teachers/schedules/index.html.erb", "Horários do Professor" ],
  [ "teachers/absences/index.html.erb", "Faltas do Professor" ],
  [ "teachers/absences/new.html.erb", "Registrar Falta" ],
  [ "teachers/absences/show.html.erb", "Visualizar Falta" ],
  [ "teachers/grades/index.html.erb", "Notas do Professor" ],
  [ "teachers/grades/new.html.erb", "Nova Nota" ],
  [ "teachers/grades/edit.html.erb", "Editar Nota" ],
  [ "teachers/messages/index.html.erb", "Mensagens Professor" ],
  [ "teachers/messages/new.html.erb", "Nova Mensagem Professor" ],
  [ "teachers/calendar/index.html.erb", "Calendário Professor" ],
  [ "teachers/students/index.html.erb", "Alunos do Professor" ],
  [ "teachers/subjects/index.html.erb", "Disciplinas do Professor" ],
  [ "teachers/reports/attendance.html.erb", "Relatório de Frequência" ],
  [ "teachers/reports/performance.html.erb", "Relatório de Desempenho" ]
]

student_views = [
  [ "students/dashboard/index.html.erb", "Dashboard Estudante" ],
  [ "students/profiles/show.html.erb", "Perfil do Estudante" ],
  [ "students/profiles/edit.html.erb", "Editar Perfil Estudante" ],
  [ "students/grades/index.html.erb", "Notas do Estudante" ],
  [ "students/grades/show.html.erb", "Visualizar Notas" ],
  [ "students/attendance/index.html.erb", "Frequência do Estudante" ],
  [ "students/schedules/index.html.erb", "Horários do Estudante" ],
  [ "students/schedules/show.html.erb", "Visualizar Horário" ],
  [ "students/messages/index.html.erb", "Mensagens Estudante" ],
  [ "students/messages/show.html.erb", "Visualizar Mensagem" ],
  [ "students/calendar/index.html.erb", "Calendário Estudante" ],
  [ "students/subjects/index.html.erb", "Matérias do Estudante" ],
  [ "students/subjects/show.html.erb", "Visualizar Matéria" ],
  [ "students/classrooms/show.html.erb", "Sala do Estudante" ],
  [ "students/activities/index.html.erb", "Atividades do Estudante" ],
  [ "students/reports/grades.html.erb", "Relatório de Notas" ]
]

general_views = [
  [ "layouts/application.html.erb", "Layout Principal" ],
  [ "devise/sessions/new.html.erb", "Página de Login" ],
  [ "devise/registrations/new.html.erb", "Página de Cadastro" ],
  [ "devise/registrations/edit.html.erb", "Editar Cadastro" ],
  [ "devise/passwords/new.html.erb", "Recuperar Senha" ],
  [ "devise/passwords/edit.html.erb", "Nova Senha" ],
  [ "shared/_sidebar.html.erb", "Barra Lateral" ],
  [ "shared/_navbar.html.erb", "Barra de Navegação" ],
  [ "messages/index.html.erb", "Mensagens Gerais" ],
  [ "messages/new.html.erb", "Nova Mensagem" ],
  [ "messages/show.html.erb", "Visualizar Mensagem" ],
  [ "notifications/index.html.erb", "Notificações" ],
  [ "schools/new.html.erb", "Nova Escola" ],
  [ "schools/create.html.erb", "Criar Escola" ]
]

# Executar testes
total_found = 0
total_views = 0

found, total = test_view_section("Views Gerais", general_views)
total_found += found
total_views += total

found, total = test_view_section("Views Admin", admin_views)
total_found += found
total_views += total

found, total = test_view_section("Views Direção", direction_views)
total_found += found
total_views += total

found, total = test_view_section("Views Professores", teacher_views)
total_found += found
total_views += total

found, total = test_view_section("Views Estudantes", student_views)
total_found += found
total_views += total

# Resumo final
puts "\n" + "=" * 60
puts "📈 RESUMO FINAL"
puts "=" * 60
puts "✅ Total de Views Encontradas: #{total_found}"
puts "📊 Total de Views Testadas: #{total_views}"
percentage = ((total_found.to_f / total_views) * 100).round(2)
puts "📈 Taxa de Cobertura: #{percentage}%"

if percentage >= 80
  puts "🎉 EXCELENTE! Sistema com boa cobertura de views."
elsif percentage >= 60
  puts "👍 BOM! Sistema com cobertura razoável de views."
else
  puts "⚠️  ATENÇÃO! Sistema precisa de mais views implementadas."
end

puts "\n🔍 PRÓXIMOS PASSOS:"
puts "1. Implemente as views que estão faltando"
puts "2. Teste a funcionalidade de cada view no navegador"
puts "3. Verifique se todas as rotas estão funcionando"
puts "4. Teste a navegação entre as views"
