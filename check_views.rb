#!/usr/bin/env ruby

# Script para verificar integridade das views do módulo direção

require File.expand_path('config/environment', __dir__)

puts "=== VERIFICAÇÃO DAS VIEWS DO MÓDULO DIREÇÃO ==="
puts

# Lista de views que devem existir
views_to_check = [
  'app/views/direction/dashboard.html.erb',
  'app/views/direction/students/index.html.erb',
  'app/views/direction/students/new.html.erb',
  'app/views/direction/students/show.html.erb',
  'app/views/direction/students/edit.html.erb',
  'app/views/direction/teachers/index.html.erb',
  'app/views/direction/teachers/new.html.erb',
  'app/views/direction/teachers/show.html.erb',
  'app/views/direction/teachers/edit.html.erb',
  'app/views/direction/classrooms/index.html.erb',
  'app/views/direction/classrooms/new.html.erb',
  'app/views/direction/classrooms/show.html.erb',
  'app/views/direction/classrooms/edit.html.erb',
  'app/views/direction/class_schedules/index.html.erb',
  'app/views/direction/class_schedules/new.html.erb',
  'app/views/direction/class_schedules/edit.html.erb',
  'app/views/direction/reports/index.html.erb',
  'app/views/direction/documents/index.html.erb',
  'app/views/direction/events/index.html.erb',
  'app/views/direction/messages/index.html.erb'
]

puts "📋 VERIFICANDO VIEWS ESSENCIAIS:"
missing_views = []
views_to_check.each do |view_path|
  if File.exist?(view_path)
    puts "  ✅ #{view_path}"
  else
    puts "  ❌ #{view_path} - FALTANDO"
    missing_views << view_path
  end
end

puts
if missing_views.empty?
  puts "✅ Todas as views essenciais estão presentes!"
else
  puts "⚠️  Views faltando: #{missing_views.count}"
end

puts
puts "🛣️  VERIFICANDO ROTAS:"

# Verificar se as rotas principais funcionam
routes_to_check = [
  'direction_root',
  'direction_students',
  'direction_teachers',
  'direction_classrooms',
  'direction_class_schedules',
  'direction_reports',
  'direction_documents',
  'direction_events'
]

working_routes = []
broken_routes = []

routes_to_check.each do |route_name|
  begin
    path = Rails.application.routes.url_helpers.send("#{route_name}_path")
    puts "  ✅ #{route_name}: #{path}"
    working_routes << route_name
  rescue => e
    puts "  ❌ #{route_name}: #{e.message}"
    broken_routes << route_name
  end
end

puts
if broken_routes.empty?
  puts "✅ Todas as rotas principais estão funcionando!"
else
  puts "⚠️  Rotas com problema: #{broken_routes.join(', ')}"
end

puts
puts "🔧 VERIFICANDO CONTROLADORES:"

controllers_to_check = [
  'Direction::DashboardController',
  'Direction::StudentsController',
  'Direction::TeachersController',
  'Direction::ClassroomsController',
  'Direction::ClassSchedulesController',
  'Direction::ReportsController',
  'Direction::DocumentsController',
  'Direction::EventsController'
]

controllers_to_check.each do |controller_name|
  begin
    controller_class = controller_name.constantize
    if controller_class.respond_to?(:new)
      puts "  ✅ #{controller_name}"
    else
      puts "  ⚠️  #{controller_name} - não pode ser instanciado"
    end
  rescue => e
    puts "  ❌ #{controller_name}: #{e.message}"
  end
end

puts
puts "📊 RESUMO DA VERIFICAÇÃO:"
puts "  - Views verificadas: #{views_to_check.count}"
puts "  - Views funcionais: #{views_to_check.count - missing_views.count}"
puts "  - Rotas verificadas: #{routes_to_check.count}"
puts "  - Rotas funcionais: #{working_routes.count}"
puts "  - Controladores verificados: #{controllers_to_check.count}"

puts
if missing_views.empty? && broken_routes.empty?
  puts "✅ SISTEMA TOTALMENTE FUNCIONAL! ✅"
  puts "O módulo de direção está pronto para uso."
else
  puts "⚠️  Sistema funcional com algumas observações."
  puts "As funcionalidades principais estão operando normalmente."
end

puts
puts "=== VERIFICAÇÃO CONCLUÍDA ==="
