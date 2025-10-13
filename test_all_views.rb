#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

class ViewTester
  def initialize(base_url = 'http://localhost:3000')
    @base_url = base_url
    @errors = []
    @successes = []
    @cookies = {}
  end

  def test_url(path, description, expected_status = 200)
    begin
      uri = URI("#{@base_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.path)

      # Add cookies if available
      if @cookies.any?
        cookie_string = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
        request['Cookie'] = cookie_string
      end

      response = http.request(request)

      # Store cookies for future requests
      if response['Set-Cookie']
        response['Set-Cookie'].split(';').each do |cookie|
          name, value = cookie.split('=', 2)
          @cookies[name.strip] = value&.strip if name && value
        end
      end

      if response.code.to_i == expected_status
        @successes << "✓ #{description} - #{path} (#{response.code})"
        puts "✓ #{description} - #{path} (#{response.code})"
      else
        @errors << "✗ #{description} - #{path} (Expected: #{expected_status}, Got: #{response.code})"
        puts "✗ #{description} - #{path} (Expected: #{expected_status}, Got: #{response.code})"
      end
    rescue => e
      @errors << "✗ ERROR: #{description} - #{path} (#{e.message})"
      puts "✗ ERROR: #{description} - #{path} (#{e.message})"
    end
  end

  def login_as(email, password, role)
    begin
      # First get the login page to extract CSRF token
      uri = URI("#{@base_url}/users/sign_in")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.path)

      response = http.request(request)

      # Extract CSRF token from response body
      csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1] rescue nil

      # Store session cookies
      if response['Set-Cookie']
        response['Set-Cookie'].split(';').each do |cookie|
          name, value = cookie.split('=', 2)
          @cookies[name.strip] = value&.strip if name && value
        end
      end

      # Perform login
      uri = URI("#{@base_url}/users/sign_in")
      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      # Add cookies
      if @cookies.any?
        cookie_string = @cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
        request['Cookie'] = cookie_string
      end

      # Prepare form data
      form_data = {
        'user[email]' => email,
        'user[password]' => password,
        'authenticity_token' => csrf_token,
        'commit' => 'Log in'
      }

      request.body = URI.encode_www_form(form_data)

      response = http.request(request)

      # Update cookies
      if response['Set-Cookie']
        response['Set-Cookie'].split(';').each do |cookie|
          name, value = cookie.split('=', 2)
          @cookies[name.strip] = value&.strip if name && value
        end
      end

      if response.code.to_i == 302 || response.code.to_i == 200
        puts "✓ Login realizado como #{role}: #{email}"
        true
      else
        puts "✗ Falha no login como #{role}: #{email} (#{response.code})"
        false
      end

    rescue => e
      puts "✗ ERRO no login como #{role}: #{email} (#{e.message})"
      false
    end
  end

  def test_admin_views
    puts "\n=== TESTANDO VIEWS ADMIN ==="

    # Admin Dashboard e Principal
    test_url('/admin', 'Admin Dashboard')

    # Escolas
    test_url('/admin/schools', 'Lista de Escolas Admin')
    test_url('/admin/schools/new', 'Nova Escola Admin')

    # Usuários
    test_url('/admin/users', 'Lista de Usuários Admin')
    test_url('/admin/users/new', 'Novo Usuário Admin')

    # Direções
    test_url('/admin/directions', 'Lista de Direções Admin')
    test_url('/admin/directions/new', 'Nova Direção Admin')

    # Eventos
    test_url('/admin/events', 'Lista de Eventos Admin')
    test_url('/admin/events/new', 'Novo Evento Admin')

    # Documentos
    test_url('/admin/documents', 'Lista de Documentos Admin')
    test_url('/admin/documents/new', 'Novo Documento Admin')

    # Mensagens
    test_url('/admin/messages', 'Lista de Mensagens Admin')
    test_url('/admin/messages/new', 'Nova Mensagem Admin')

    # Relatórios
    test_url('/admin/reports/municipal_overview', 'Relatório Municipal Admin')
    test_url('/admin/reports/attendance_report', 'Relatório de Frequência Admin')
    test_url('/admin/reports/performance_report', 'Relatório de Desempenho Admin')
    test_url('/admin/reports/student_distribution', 'Distribuição de Estudantes Admin')
  end

  def test_direction_views
    puts "\n=== TESTANDO VIEWS DIREÇÃO ==="

    # Dashboard da Direção
    test_url('/direction', 'Dashboard Direção')

    # Escola da Direção
    test_url('/direction/school', 'Escola da Direção')
    test_url('/direction/school/edit', 'Editar Escola Direção')

    # Professores
    test_url('/direction/teachers', 'Lista de Professores Direção')
    test_url('/direction/teachers/new', 'Novo Professor Direção')

    # Estudantes
    test_url('/direction/students', 'Lista de Estudantes Direção')
    test_url('/direction/students/new', 'Novo Estudante Direção')

    # Salas de Aula
    test_url('/direction/classrooms', 'Lista de Salas Direção')
    test_url('/direction/classrooms/new', 'Nova Sala Direção')

    # Matérias
    test_url('/direction/subjects', 'Lista de Matérias Direção')
    test_url('/direction/subjects/new', 'Nova Matéria Direção')

    # Eventos
    test_url('/direction/events', 'Lista de Eventos Direção')
    test_url('/direction/events/new', 'Novo Evento Direção')

    # Mensagens
    test_url('/direction/messages', 'Lista de Mensagens Direção')

    # Relatórios
    test_url('/direction/reports/attendance_report', 'Relatório de Frequência Direção')
    test_url('/direction/reports/performance_report', 'Relatório de Desempenho Direção')
    test_url('/direction/reports/teacher_performance', 'Desempenho dos Professores Direção')
  end

  def test_teacher_views
    puts "\n=== TESTANDO VIEWS PROFESSORES ==="

    # Dashboard do Professor
    test_url('/teachers', 'Dashboard Professor')

    # Perfil do Professor
    test_url('/teachers/profile', 'Perfil do Professor')
    test_url('/teachers/profile/edit', 'Editar Perfil Professor')

    # Salas de Aula do Professor
    test_url('/teachers/classrooms', 'Salas de Aula do Professor')

    # Horários do Professor
    test_url('/teachers/schedules', 'Horários do Professor')

    # Faltas do Professor
    test_url('/teachers/absences', 'Faltas do Professor')
    test_url('/teachers/absences/new', 'Registrar Falta Professor')

    # Notas do Professor
    test_url('/teachers/grades', 'Notas do Professor')

    # Mensagens do Professor
    test_url('/teachers/messages', 'Mensagens do Professor')
    test_url('/teachers/messages/new', 'Nova Mensagem Professor')

    # Calendário do Professor
    test_url('/teachers/calendar', 'Calendário do Professor')
  end

  def test_student_views
    puts "\n=== TESTANDO VIEWS ESTUDANTES ==="

    # Dashboard do Estudante
    test_url('/students', 'Dashboard Estudante')
    test_url('/students/dashboard', 'Dashboard Estudante Alt')

    # Perfil do Estudante
    test_url('/students/profile', 'Perfil do Estudante')
    test_url('/students/profiles', 'Perfis de Estudantes')

    # Notas do Estudante
    test_url('/students/grades', 'Notas do Estudante')

    # Frequência do Estudante
    test_url('/students/attendance', 'Frequência do Estudante')

    # Horários do Estudante
    test_url('/students/schedule', 'Horário do Estudante')
    test_url('/students/schedules', 'Horários do Estudante')

    # Mensagens do Estudante
    test_url('/students/messages', 'Mensagens do Estudante')

    # Calendário do Estudante
    test_url('/students/calendar', 'Calendário do Estudante')

    # Matérias do Estudante
    test_url('/students/subjects', 'Matérias do Estudante')
  end

  def test_general_views
    puts "\n=== TESTANDO VIEWS GERAIS ==="

    # Páginas Principais
    test_url('/', 'Página Inicial')
    test_url('/users/sign_in', 'Login')
    test_url('/users/sign_up', 'Cadastro')

    # Mensagens Gerais
    test_url('/messages', 'Mensagens Gerais')

    # Escolas
    test_url('/schools', 'Lista de Escolas')
    test_url('/schools/new', 'Nova Escola')

    # Teste
    test_url('/test', 'Página de Teste')
  end

  def test_with_login
    puts "🚀 INICIANDO TESTES COM LOGIN DE TODAS AS VIEWS"
    puts "Base URL: #{@base_url}"
    puts "=" * 50

    # Test public views first
    test_general_views

    # Test Admin views
    @cookies.clear
    if login_as('admin@sistema.com', '123456', 'admin')
      test_admin_views
    end

    # Test Direction views
    @cookies.clear
    if login_as('direcao@escola.com', 'password123', 'direction')
      test_direction_views
    end

    # Test Teacher views
    @cookies.clear
    if login_as('professor1@escola.com', 'password123', 'teacher')
      test_teacher_views
    end

    # Test Student views
    @cookies.clear
    if login_as('aluno1@escola.com', 'password123', 'student')
      test_student_views
    end

    print_summary
  end

  def run_all_tests
    puts "🚀 INICIANDO TESTES BÁSICOS DE TODAS AS VIEWS"
    puts "Base URL: #{@base_url}"
    puts "=" * 50

    test_general_views
    test_admin_views
    test_direction_views
    test_teacher_views
    test_student_views

    print_summary
  end

  def print_summary
    puts "\n" + "=" * 50
    puts "📊 RESUMO DOS TESTES"
    puts "=" * 50
    puts "✅ Sucessos: #{@successes.count}"
    puts "❌ Erros: #{@errors.count}"
    puts "📈 Taxa de Sucesso: #{(@successes.count.to_f / (@successes.count + @errors.count) * 100).round(2)}%"

    if @errors.any?
      puts "\n❌ ERROS ENCONTRADOS:"
      @errors.each { |error| puts "  #{error}" }
    end

    puts "\n✅ SUCESSOS:"
    @successes.each { |success| puts "  #{success}" }
  end
end

# Executar testes
if __FILE__ == $0
  tester = ViewTester.new
  puts "Escolha o tipo de teste:"
  puts "1. Testes básicos (sem login)"
  puts "2. Testes completos (com login)"
  puts ""

  # Para automatizar, vamos usar os testes com login
  tester.test_with_login
end
