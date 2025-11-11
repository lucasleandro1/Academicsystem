# Script para criar eventos de exemplo no calendário acadêmico

# Criar eventos municipais importantes
municipal_events = [
  {
    title: "Início do Ano Letivo 2025",
    description: "Primeiro dia de aulas do ano letivo de 2025 em todas as escolas municipais.",
    date: Date.new(2025, 2, 5),
    calendar_type: "school_start",
    all_schools: true
  },
  {
    title: "Carnaval",
    description: "Feriado nacional de Carnaval. Não haverá aulas.",
    date: Date.new(2025, 2, 24),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Carnaval",
    description: "Feriado nacional de Carnaval. Não haverá aulas.",
    date: Date.new(2025, 2, 25),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Dia da Consciência Negra",
    description: "Feriado municipal em celebração ao Dia da Consciência Negra.",
    date: Date.new(2025, 11, 20),
    calendar_type: "municipal_holiday",
    all_schools: true
  },
  {
    title: "Férias de Julho",
    description: "Recesso escolar de julho para todas as escolas municipais.",
    date: Date.new(2025, 7, 15),
    calendar_type: "vacation",
    all_schools: true
  },
  {
    title: "Férias de Julho",
    description: "Recesso escolar de julho para todas as escolas municipais.",
    date: Date.new(2025, 7, 16),
    calendar_type: "vacation",
    all_schools: true
  },
  {
    title: "Férias de Julho",
    description: "Recesso escolar de julho para todas as escolas municipais.",
    date: Date.new(2025, 7, 17),
    calendar_type: "vacation",
    all_schools: true
  },
  {
    title: "Férias de Julho",
    description: "Recesso escolar de julho para todas as escolas municipais.",
    date: Date.new(2025, 7, 18),
    calendar_type: "vacation",
    all_schools: true
  },
  {
    title: "Sexta-feira Santa",
    description: "Feriado religioso nacional. Não haverá aulas.",
    date: Date.new(2025, 4, 18),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Dia do Trabalhador",
    description: "Feriado nacional do Dia do Trabalhador.",
    date: Date.new(2025, 5, 1),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Independência do Brasil",
    description: "Feriado nacional da Independência do Brasil.",
    date: Date.new(2025, 9, 7),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Nossa Senhora Aparecida",
    description: "Feriado nacional de Nossa Senhora Aparecida, Padroeira do Brasil.",
    date: Date.new(2025, 10, 12),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Finados",
    description: "Feriado nacional de Finados.",
    date: Date.new(2025, 11, 2),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Proclamação da República",
    description: "Feriado nacional da Proclamação da República.",
    date: Date.new(2025, 11, 15),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Natal",
    description: "Feriado nacional de Natal.",
    date: Date.new(2025, 12, 25),
    calendar_type: "holiday",
    all_schools: true
  },
  {
    title: "Fim do Ano Letivo 2025",
    description: "Último dia de aulas do ano letivo de 2025.",
    date: Date.new(2025, 12, 15),
    calendar_type: "school_end",
    all_schools: true
  },
  {
    title: "Reunião Pedagógica - 1º Bimestre",
    description: "Reunião pedagógica para avaliação do primeiro bimestre.",
    date: Date.new(2025, 4, 25),
    calendar_type: "meeting",
    all_schools: true
  },
  {
    title: "Dia Pedagógico - Formação Continuada",
    description: "Dia dedicado à formação continuada dos professores.",
    date: Date.new(2025, 3, 15),
    calendar_type: "pedagogical_day",
    all_schools: true
  }
]

puts "Criando eventos municipais do calendário acadêmico..."

municipal_events.each do |event_data|
  calendar = Calendar.create!(event_data)
  puts "✓ Criado: #{calendar.title} - #{calendar.date.strftime('%d/%m/%Y')}"
end

puts "\n#{municipal_events.count} eventos municipais criados com sucesso!"
puts "Os eventos são visíveis para todos os usuários (direção, professores e estudantes)."
