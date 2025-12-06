# Reset Database and create comprehensive seed data
# This seed file creates a complete academic system with:
# - 1 High School with directors and coordinators
# - Teachers for all subjects
# - 5 classes with 30 students each
# - Class schedules
# - Grades, absences, documents for 3rd semester

puts "🗑️  Limpando banco de dados..."

# Clear all data in order
ClassSchedule.delete_all
Grade.delete_all
Absence.delete_all
Document.delete_all
Message.delete_all
Event.delete_all
Subject.delete_all
User.delete_all
Classroom.delete_all
School.delete_all

puts "✅ Banco de dados limpo!"

puts "👨‍💼 Criando admins..."

# Create Admin Users FIRST (before schools)
admin1 = User.create!(
  email: 'admin@sistema.com',
  password: '123456',
  password_confirmation: '123456',
  user_type: 'admin',
  first_name: 'Sistema',
  last_name: 'Administrativo'
)

admin2 = User.create!(
  email: 'admin2@sistema.com',
  password: '123456',
  password_confirmation: '123456',
  user_type: 'admin',
  first_name: 'João',
  last_name: 'Administrador'
)

admin3 = User.create!(
  email: 'admin3@sistema.com',
  password: '123456',
  password_confirmation: '123456',
  user_type: 'admin',
  first_name: 'Maria',
  last_name: 'Gestora'
)

puts "✅ #{User.admin.count} Admins criados"

puts "🏫 Criando escolas..."

# Create Schools (after admins are created)
school1 = School.create!(
  name: 'Colégio Estadual Dom Pedro II',
  cnpj: '12.345.678/0001-90',
  address: 'Rua da Educação, 456 - Centro - São Paulo/SP',
  phone: '(11) 3456-7890',
  email: 'secretaria@dompedroii.edu.br'
)

school2 = School.create!(
  name: 'Escola Municipal Santos Dumont',
  cnpj: '98.765.432/0001-10',
  address: 'Av. dos Estudantes, 1200 - Vila Nova - São Paulo/SP',
  phone: '(11) 3789-4560',
  email: 'contato@santosdumont.edu.br'
)

school3 = School.create!(
  name: 'Instituto Educacional Rui Barbosa',
  cnpj: '45.678.901/0001-23',
  address: 'Rua das Letras, 789 - Jardim das Flores - São Paulo/SP',
  phone: '(11) 3654-9870',
  email: 'secretaria@ruibarbosa.edu.br'
)

puts "✅ #{School.count} Escolas criadas"

# Continue with School 1 (Dom Pedro II)
school = school1

# Create Direction Users (Director + Coordinator)
director = User.create!(
  email: 'diretor@dompedroii.edu.br',
  password: 'diretor123',
  password_confirmation: 'diretor123',
  user_type: 'direction',
  school: school,
  first_name: 'Roberto',
  last_name: 'Silva Diretor',
  phone: '(11) 99876-5432'
)

coordinator = User.create!(
  email: 'coordenacao@dompedroii.edu.br',
  password: 'coord123',
  password_confirmation: 'coord123',
  user_type: 'direction',
  school: school,
  first_name: 'Mariana',
  last_name: 'Santos Coordenadora',
  phone: '(11) 98765-4321'
)

puts "✅ Direção criada: #{director.full_name} e #{coordinator.full_name}"

# Create Teachers for High School Subjects
teachers_data = [
  { name: 'Carlos Alberto', last: 'Matemática', email: 'carlos.matematica@dompedroii.edu.br', subject: 'Matemática' },
  { name: 'Ana Beatriz', last: 'Português', email: 'ana.portugues@dompedroii.edu.br', subject: 'Língua Portuguesa' },
  { name: 'José Ricardo', last: 'Física', email: 'jose.fisica@dompedroii.edu.br', subject: 'Física' },
  { name: 'Maria Clara', last: 'Química', email: 'maria.quimica@dompedroii.edu.br', subject: 'Química' },
  { name: 'Pedro Paulo', last: 'Biologia', email: 'pedro.biologia@dompedroii.edu.br', subject: 'Biologia' },
  { name: 'Fernanda', last: 'História', email: 'fernanda.historia@dompedroii.edu.br', subject: 'História' },
  { name: 'Ricardo', last: 'Geografia', email: 'ricardo.geografia@dompedroii.edu.br', subject: 'Geografia' },
  { name: 'Juliana', last: 'Inglês', email: 'juliana.ingles@dompedroii.edu.br', subject: 'Inglês' },
  { name: 'Marcos', last: 'Educação Física', email: 'marcos.edfisica@dompedroii.edu.br', subject: 'Educação Física' },
  { name: 'Lucia', last: 'Filosofia', email: 'lucia.filosofia@dompedroii.edu.br', subject: 'Filosofia' },
  { name: 'Bruno', last: 'Sociologia', email: 'bruno.sociologia@dompedroii.edu.br', subject: 'Sociologia' },
  { name: 'Carla', last: 'Artes', email: 'carla.artes@dompedroii.edu.br', subject: 'Artes' }
]

teachers = {}
teachers_data.each do |teacher_data|
  teacher = User.create!(
    email: teacher_data[:email],
    password: 'professor123',
    password_confirmation: 'professor123',
    user_type: 'teacher',
    school: school,
    first_name: teacher_data[:name],
    last_name: teacher_data[:last],
    phone: "(11) #{rand(90000000..99999999)}"
  )
  teachers[teacher_data[:subject]] = teacher
end

puts "✅ #{teachers.count} professores criados"

# Create 5 Classrooms (High School)
classrooms = []
[ '1º Ano A', '1º Ano B', '2º Ano A', '2º Ano B', '3º Ano A' ].each_with_index do |name, index|
  shift = index < 2 ? 'morning' : (index < 4 ? 'afternoon' : 'morning')
  classroom = Classroom.create!(
    name: name,
    academic_year: Date.current.year,
    shift: shift,
    level: 'high_school',
    school: school
  )
  classrooms << classroom
end

puts "✅ #{classrooms.count} turmas criadas"

# Create 30 students for each classroom (150 total)
all_students = []
student_names = [
  'Ana Silva', 'Bruno Santos', 'Carla Oliveira', 'Daniel Costa', 'Eduarda Lima',
  'Felipe Pereira', 'Gabriela Alves', 'Hugo Ferreira', 'Isabela Rodrigues', 'João Martins',
  'Larissa Souza', 'Mateus Ribeiro', 'Natália Cardoso', 'Otávio Nascimento', 'Patrícia Gomes',
  'Rafael Barbosa', 'Sofia Mendes', 'Thiago Moura', 'Valentina Cruz', 'Wesley Dias',
  'Ximena Torres', 'Yuri Campos', 'Zara Viana', 'André Lopes', 'Beatriz Nunes',
  'Caio Rocha', 'Débora Freitas', 'Enzo Cavalcanti', 'Flávia Monteiro', 'Guilherme Teixeira'
]

guardian_names = [
  'José da Silva', 'Maria Santos', 'Carlos Oliveira', 'Ana Costa', 'Pedro Lima',
  'Lucia Pereira', 'Roberto Alves', 'Fernanda Ferreira', 'Marcos Rodrigues', 'Juliana Martins'
]

classrooms.each_with_index do |classroom, class_index|
  30.times do |i|
    base_name = student_names[i % student_names.length]
    first_name, last_name = base_name.split(' ')

    student = User.create!(
      email: "#{first_name.downcase}.#{last_name.downcase}.#{class_index+1}.#{i+1}@aluno.dompedroii.edu.br",
      password: 'aluno123',
      password_confirmation: 'aluno123',
      user_type: 'student',
      school: school,
      classroom: classroom,
      first_name: first_name,
      last_name: "#{last_name} #{class_index+1}#{i+1}",
      birth_date: Date.new(2006 + rand(0..2), rand(1..12), rand(1..28)),
      guardian_name: guardian_names[i % guardian_names.length]
    )
    all_students << student
  end
end

puts "✅ #{all_students.count} alunos criados (30 por turma)"

# Create Subjects (unique subjects that can be shared across classrooms)
subjects_data = [
  { name: 'Matemática', area: 'mathematics', teacher: 'Matemática' },
  { name: 'Língua Portuguesa', area: 'languages', teacher: 'Língua Portuguesa' },
  { name: 'Física', area: 'natural_sciences', teacher: 'Física' },
  { name: 'Química', area: 'natural_sciences', teacher: 'Química' },
  { name: 'Biologia', area: 'natural_sciences', teacher: 'Biologia' },
  { name: 'História', area: 'human_sciences', teacher: 'História' },
  { name: 'Geografia', area: 'human_sciences', teacher: 'Geografia' },
  { name: 'Inglês', area: 'languages', teacher: 'Inglês' },
  { name: 'Educação Física', area: 'physical_education', teacher: 'Educação Física' },
  { name: 'Filosofia', area: 'human_sciences', teacher: 'Filosofia' },
  { name: 'Sociologia', area: 'human_sciences', teacher: 'Sociologia' },
  { name: 'Artes', area: 'arts', teacher: 'Artes' }
]

# Create unique subjects (not tied to specific classrooms)
all_subjects = {}
subjects_data.each do |subject_data|
  subject = Subject.create!(
    name: subject_data[:name],
    classroom: nil, # NÃO vinculada à turma específica - pode ser compartilhada
    school: school,
    user: teachers[subject_data[:teacher]],
    workload: 1, # Será atualizado baseado nos horários criados
    area: subject_data[:area],
    code: subject_data[:name].gsub(' ', '')[0..4].upcase,
    description: "Disciplina de #{subject_data[:name]}"
  )
  all_subjects[subject_data[:name]] = subject
end

puts "✅ #{all_subjects.count} disciplinas únicas criadas (compartilháveis entre turmas)"

# Create Class Schedules (weekly schedule) - This is where subjects get associated to classrooms
puts "📅 Criando horários das aulas..."

# Time slots for morning (7:00-12:00) and afternoon (13:00-18:00)
morning_times = [
  [ '07:00', '07:50' ], [ '07:50', '08:40' ], [ '08:40', '09:30' ],
  [ '09:50', '10:40' ], [ '10:40', '11:30' ], [ '11:30', '12:20' ]
]

afternoon_times = [
  [ '13:00', '13:50' ], [ '13:50', '14:40' ], [ '14:40', '15:30' ],
  [ '15:50', '16:40' ], [ '16:40', '17:30' ], [ '17:30', '18:20' ]
]

# Subject workload per year (how many slots per week each subject gets)
workload_per_year = {
  '1º Ano' => {
    'Matemática' => 5, 'Língua Portuguesa' => 5, 'Física' => 3, 'Química' => 3,
    'Biologia' => 3, 'História' => 3, 'Geografia' => 3, 'Inglês' => 2,
    'Educação Física' => 2, 'Filosofia' => 1, 'Sociologia' => 1, 'Artes' => 1
  },
  '2º Ano' => {
    'Matemática' => 5, 'Língua Portuguesa' => 5, 'Física' => 4, 'Química' => 4,
    'Biologia' => 3, 'História' => 3, 'Geografia' => 3, 'Inglês' => 2,
    'Educação Física' => 2, 'Filosofia' => 1, 'Sociologia' => 1
  },
  '3º Ano' => {
    'Matemática' => 6, 'Língua Portuguesa' => 6, 'Física' => 4, 'Química' => 4,
    'Biologia' => 4, 'História' => 3, 'Geografia' => 3, 'Inglês' => 2,
    'Educação Física' => 2, 'Filosofia' => 2, 'Sociologia' => 2
  }
}

# Track teacher schedules to avoid conflicts
teacher_schedules = {}
teachers.values.each { |teacher| teacher_schedules[teacher.id] = {} }

classrooms.each do |classroom|
  times = classroom.shift == 'morning' ? morning_times : afternoon_times
  year_key = classroom.name.split(' ').first
  classroom_workload = workload_per_year[year_key] || workload_per_year['1º Ano']

  # Create a list of subjects with their slots based on workload
  # Now using the shared subjects from all_subjects hash
  subjects_with_slots = []
  classroom_workload.each do |subject_name, slots|
    subject = all_subjects[subject_name]
    next unless subject

    slots.times { subjects_with_slots << subject }
  end

  subjects_with_slots.shuffle!

  # Assign to time slots (6 periods per day, 5 days = 30 slots per week)
  slot_index = 0
  (1..5).each do |weekday| # Monday to Friday
    times.each_with_index do |time_slot, period|
      break if slot_index >= subjects_with_slots.length

      subject = subjects_with_slots[slot_index]
      teacher = subject.user

      # Create a unique time slot key
      time_key = "#{weekday}_#{time_slot[0]}_#{time_slot[1]}"

      # Check if teacher already has a class at this time
      if teacher_schedules[teacher.id][time_key]
        # Skip this slot and try next subject
        slot_index += 1
        redo if slot_index < subjects_with_slots.length
        next
      end

      # Mark this time slot as occupied for the teacher
      teacher_schedules[teacher.id][time_key] = true

      ClassSchedule.create!(
        classroom: classroom,
        subject: subject,
        school: school,
        weekday: weekday,
        start_time: Time.parse(time_slot[0]),
        end_time: Time.parse(time_slot[1]),
        period: classroom.shift == 'morning' ? 'matutino' : 'vespertino',
        class_order: period + 1,
        active: true
      )

      slot_index += 1
    end
  end
end

# Update subject workloads based on created schedules
all_subjects.values.each do |subject|
  total_workload = ClassSchedule.where(subject: subject).count
  # Ensure workload is at least 1 to pass validation
  subject.update!(workload: [ total_workload, 1 ].max)
end

puts "✅ Horários das aulas criados"

# Create Grades for 3rd Semester (considering we're in the 3rd semester)
puts "📊 Criando notas do 3º semestre..."

grade_types = [ 'prova', 'trabalho', 'atividade', 'participacao' ]
assessment_names = {
  'prova' => [ 'Prova Bimestral', 'Avaliação Mensal', 'Teste' ],
  'trabalho' => [ 'Trabalho em Grupo', 'Pesquisa Individual', 'Projeto' ],
  'atividade' => [ 'Exercícios', 'Lista de Exercícios', 'Atividade Prática' ],
  'participacao' => [ 'Participação em Aula', 'Seminário', 'Apresentação' ]
}

bimester = 3 # 3rd semester
all_subjects.values.each do |subject|
  students = subject.students

  students.each do |student|
    # Create 3-5 grades per student per subject
    rand(3..5).times do |grade_index|
      grade_type = grade_types.sample
      max_value = case grade_type
      when 'prova' then 10.0
      when 'trabalho' then 10.0
      when 'atividade' then 5.0
      when 'participacao' then 3.0
      end

      # Generate realistic grades (most students get 60-90%)
      percentage = rand(40..95)
      value = (max_value * percentage / 100.0).round(2)

      # Create unique assessment name
      assessment_name = "#{assessment_names[grade_type].sample} #{grade_index + 1}"

      Grade.create!(
        student: student,
        subject: subject,
        school: school,
        bimester: bimester,
        value: value,
        max_value: max_value,
        grade_type: grade_type,
        assessment_name: assessment_name,
        assessment_date: Date.current - rand(1..60).days,
        teacher_notes: percentage >= 70 ? 'Bom desempenho' : 'Precisa melhorar'
      )
    end
  end
end

puts "✅ Notas criadas para o 3º bimestre"

# Create some Absences
puts "❌ Criando faltas..."

justification_reasons = [
  "Consulta médica",
  "Atestado médico",
  "Problemas familiares",
  "Compromisso inadiável",
  "Viagem em família",
  "Participação em evento esportivo",
  "Doença",
  "Comparecimento ao dentista"
]

all_subjects.values.each do |subject|
  students = subject.students

  # Some students will have absences (about 30% of students)
  students.sample(students.count * 0.3).each do |student|
    # Each student with absences will have 1-5 absences
    rand(1..5).times do
      is_justified = [ true, false ].sample
      
      Absence.create!(
        student: student,
        subject: subject,
        date: Date.current - rand(1..90).days,
        justified: is_justified,
        justification: is_justified ? justification_reasons.sample : nil
      )
    end
  end
end

puts "✅ Faltas criadas"

# Create Documents with Real Files
puts "📄 Criando documentos com arquivos reais..."

seed_files_dir = File.join(Rails.root, 'db', 'seed_files')

# Define document data with real files
documents_with_files = [
  {
    title: 'Regulamento Escolar 2025',
    document_type: 'regulamento',
    description: 'Regulamento oficial da escola contendo todas as normas e diretrizes.',
    file: 'regulamento_escolar.pdf',
    user: director,
    sharing_type: 'all_students'
  },
  {
    title: 'Comunicado - Reunião de Pais 3º Bimestre',
    document_type: 'comunicado',
    description: 'Comunicado oficial sobre a reunião de pais do 3º bimestre.',
    file: 'comunicado_reuniao.pdf',
    user: director,
    sharing_type: 'all_students'
  },
  {
    title: 'Circular Nº 001/2025 - Normas 4º Bimestre',
    document_type: 'circular',
    description: 'Circular informativa sobre as normas e datas do 4º bimestre.',
    file: 'circular_001.txt',
    user: coordinator,
    sharing_type: 'all_students'
  },
  {
    title: 'Ata da Reunião Pedagógica - Outubro/2025',
    document_type: 'ata',
    description: 'Ata oficial da reunião pedagógica realizada em outubro.',
    file: 'ata_reuniao.txt',
    user: director,
    sharing_type: 'all_students'
  },
  {
    title: 'Modelo de Histórico Escolar',
    document_type: 'historico',
    description: 'Modelo padrão de histórico escolar da instituição.',
    file: 'historico_escolar.pdf',
    user: coordinator,
    sharing_type: 'all_students'
  },
  {
    title: 'Histórico Escolar Completo - Modelo',
    document_type: 'historico',
    description: 'Histórico escolar detalhado em formato HTML para visualização.',
    file: 'historico_completo.html',
    user: coordinator,
    sharing_type: 'all_students'
  },
  {
    title: 'Declaração de Matrícula - Modelo',
    document_type: 'declaracao',
    description: 'Modelo de declaração de matrícula para alunos.',
    file: 'declaracao_matricula.pdf',
    user: director,
    sharing_type: 'all_students'
  },
  {
    title: 'Certificado de Participação - Feira de Ciências',
    document_type: 'certificado',
    description: 'Modelo de certificado para participantes da Feira de Ciências.',
    file: 'certificado_feira.html',
    user: director,
    sharing_type: 'all_students'
  },
  {
    title: 'Relatório Pedagógico - 3º Bimestre',
    document_type: 'outros',
    description: 'Relatório com dados estatísticos e metas pedagógicas.',
    file: 'relatorio_pedagogico.json',
    user: coordinator,
    sharing_type: 'all_students'
  }
]

# Create documents with file attachments
documents_with_files.each do |doc_data|
  file_path = File.join(seed_files_dir, doc_data[:file])

  if File.exist?(file_path)
    document = Document.create!(
      title: doc_data[:title],
      document_type: doc_data[:document_type],
      description: doc_data[:description],
      school: school,
      user: doc_data[:user],
      is_municipal: false,
      sharing_type: doc_data[:sharing_type]
    )

    # Attach the file using Active Storage
    document.attachment.attach(
      io: File.open(file_path),
      filename: doc_data[:file],
      content_type: case File.extname(doc_data[:file])
                    when '.pdf' then 'application/pdf'
                    when '.txt' then 'text/plain'
                    when '.pbm' then 'image/x-portable-bitmap'
                    else 'application/octet-stream'
                    end
    )

    puts "✅ Documento criado com arquivo: #{doc_data[:title]} (#{doc_data[:file]})"
  else
    puts "⚠️  Arquivo não encontrado: #{file_path}"
  end
end

# Create some student-specific documents (boletins with files)
puts "📊 Criando boletins individuais com arquivos..."

# Select some students from different classrooms for individual report cards
sample_students = []
classrooms.each do |classroom|
  sample_students += classroom.students.limit(3)
end

sample_students.each_with_index do |student, index|
  # Alternate between different boletim formats
  if index % 3 == 0
    boletim_file_path = File.join(seed_files_dir, 'boletim_completo.html')
    filename = "boletim_#{student.first_name.downcase}_#{student.last_name.gsub(' ', '_').downcase}.html"
    content_type = 'text/html'
  else
    boletim_file_path = File.join(seed_files_dir, 'boletim_exemplo.pdf')
    filename = "boletim_#{student.first_name.downcase}_#{student.last_name.gsub(' ', '_').downcase}.pdf"
    content_type = 'application/pdf'
  end

  if File.exist?(boletim_file_path)
    document = Document.create!(
      title: "Boletim Escolar - #{student.full_name}",
      document_type: 'boletim',
      description: "Boletim escolar individual do 3º bimestre - #{student.full_name}",
      school: school,
      user: student,
      is_municipal: false,
      sharing_type: 'specific_student'
    )

    # Attach the file
    document.attachment.attach(
      io: File.open(boletim_file_path),
      filename: filename,
      content_type: content_type
    )

    puts "✅ Boletim criado para: #{student.full_name} (#{File.extname(filename)})"
  end
end

# Create some classroom-specific documents
puts "🏛️ Criando documentos específicos por turma..."

classrooms.sample(2).each do |classroom|
  certificate_file_path = File.join(seed_files_dir, 'certificado_template.pbm')

  if File.exist?(certificate_file_path)
    document = Document.create!(
      title: "Certificado de Participação - #{classroom.name}",
      document_type: 'certificado',
      description: "Modelo de certificado para eventos da turma #{classroom.name}",
      school: school,
      user: coordinator,
      classroom: classroom,
      is_municipal: false,
      sharing_type: 'specific_classroom'
    )

    # Attach the image file
    document.attachment.attach(
      io: File.open(certificate_file_path),
      filename: "certificado_#{classroom.name.gsub(' ', '_').downcase}.pbm",
      content_type: 'image/x-portable-bitmap'
    )

    puts "✅ Certificado criado para turma: #{classroom.name}"
  end
end

# Create visual documents with SVG images
puts "🎨 Criando documentos visuais..."

visual_docs = [
  {
    title: 'Logo Oficial da Escola',
    file: 'logo_escola.svg',
    type: 'outros',
    description: 'Logo oficial do Colégio Dom Pedro II em formato vetorial.'
  },
  {
    title: 'Gráfico de Desempenho - 3º Bimestre',
    file: 'grafico_notas.svg',
    type: 'outros',
    description: 'Gráfico com análise de desempenho por disciplina.'
  },
  {
    title: 'Foto da Feira de Ciências 2025',
    file: 'foto_feira_ciencias.svg',
    type: 'outros',
    description: 'Registro visual da Feira de Ciências realizada em outubro.'
  }
]

visual_docs.each do |doc_data|
  file_path = File.join(seed_files_dir, doc_data[:file])

  if File.exist?(file_path)
    document = Document.create!(
      title: doc_data[:title],
      document_type: doc_data[:type],
      description: doc_data[:description],
      school: school,
      user: coordinator,
      is_municipal: false,
      sharing_type: 'all_students'
    )

    document.attachment.attach(
      io: File.open(file_path),
      filename: doc_data[:file],
      content_type: 'image/svg+xml'
    )

    puts "✅ Documento visual criado: #{doc_data[:title]}"
  end
end

# Create additional documents without files (as before)
document_types = %w[comunicado circular]

document_types.each do |doc_type|
  2.times do |i|
    Document.create!(
      title: "#{doc_type.humanize} #{i + 4}",
      document_type: doc_type,
      description: "Documento adicional da escola - #{doc_type.humanize}",
      school: school,
      user: [ director, coordinator ].sample,
      is_municipal: false,
      sharing_type: 'all_students'
    )
  end
end

puts "✅ Documentos criados (com e sem arquivos anexos)"

# Create Events
puts "🎉 Criando eventos..."

events_data = [
  { title: 'Feira de Ciências', type: 'academico', description: 'Feira anual de ciências e tecnologia', days_from_now: -30 },
  { title: 'Reunião de Pais', type: 'administrativo', description: 'Reunião bimestral com pais e responsáveis', days_from_now: -15 },
  { title: 'Jogos Interclasse', type: 'esportivo', description: 'Competições esportivas entre as turmas', days_from_now: -45 },
  { title: 'Festival de Artes', type: 'cultural', description: 'Apresentações artísticas dos alunos', days_from_now: -60 },
  { title: 'Simulado ENEM', type: 'academico', description: 'Simulado preparatório para o ENEM', days_from_now: 15 },
  { title: 'Conselho de Classe', type: 'administrativo', description: 'Reunião do conselho de classe', days_from_now: 30 },
  { title: 'Formatura 3º Ano', type: 'academico', description: 'Cerimônia de formatura', days_from_now: 120 }
]

events_data.each do |event_data|
  event_date = Date.current + event_data[:days_from_now].days
  Event.create!(
    title: event_data[:title],
    description: event_data[:description],
    event_type: event_data[:type],
    start_date: event_date,
    end_date: event_date,
    start_time: Time.parse('08:00'),
    end_time: Time.parse('17:00'),
    school: school,
    is_municipal: false
  )
end

puts "✅ Eventos criados"

# Create some Messages
puts "💬 Criando mensagens..."

# Messages from direction to teachers
teachers.values.sample(10).each do |teacher|
  Message.create!(
    sender: director,
    recipient: teacher,
    school: school,
    subject: 'Reunião Pedagógica',
    body: 'Lembrete sobre a reunião pedagógica da próxima semana. Por favor, confirme sua presença.',
    read_at: rand(2) == 0 ? Time.current - rand(1..5).days : nil
  )
end

# Messages from coordinator to teachers
teachers.values.sample(8).each do |teacher|
  Message.create!(
    sender: coordinator,
    recipient: teacher,
    school: school,
    subject: 'Entrega de Notas',
    body: 'Lembramos que o prazo para entrega das notas do 3º bimestre é até sexta-feira.',
    read_at: rand(2) == 0 ? Time.current - rand(1..3).days : nil
  )
end

puts "✅ Mensagens criadas"

puts "\n" + "="*70
puts "🏫 CRIANDO DADOS PARA ESCOLA 2: #{school2.name}"
puts "="*70

# Create Direction for School 2
director2 = User.create!(
  email: 'diretor@santosdumont.edu.br',
  password: 'diretor123',
  password_confirmation: 'diretor123',
  user_type: 'direction',
  school: school2,
  first_name: 'Carlos',
  last_name: 'Mendes Diretor',
  phone: '(11) 99123-4567'
)

coordinator2 = User.create!(
  email: 'coordenacao@santosdumont.edu.br',
  password: 'coord123',
  password_confirmation: 'coord123',
  user_type: 'direction',
  school: school2,
  first_name: 'Beatriz',
  last_name: 'Lima Coordenadora',
  phone: '(11) 98456-7890'
)

puts "✅ Direção escola 2 criada"

# Create Teachers for School 2
teachers_school2_data = [
  { name: 'Eduardo', last: 'Matemática', email: 'eduardo.mat@santosdumont.edu.br', subject: 'Matemática' },
  { name: 'Patricia', last: 'Português', email: 'patricia.port@santosdumont.edu.br', subject: 'Língua Portuguesa' },
  { name: 'Rodrigo', last: 'Ciências', email: 'rodrigo.ciencias@santosdumont.edu.br', subject: 'Ciências' },
  { name: 'Simone', last: 'História', email: 'simone.historia@santosdumont.edu.br', subject: 'História' },
  { name: 'Thiago', last: 'Geografia', email: 'thiago.geo@santosdumont.edu.br', subject: 'Geografia' },
  { name: 'Vanessa', last: 'Inglês', email: 'vanessa.ingles@santosdumont.edu.br', subject: 'Inglês' },
  { name: 'Wagner', last: 'Ed. Física', email: 'wagner.edfisica@santosdumont.edu.br', subject: 'Educação Física' },
  { name: 'Yara', last: 'Artes', email: 'yara.artes@santosdumont.edu.br', subject: 'Artes' }
]

teachers_school2 = {}
teachers_school2_data.each do |teacher_data|
  teacher = User.create!(
    email: teacher_data[:email],
    password: 'professor123',
    password_confirmation: 'professor123',
    user_type: 'teacher',
    school: school2,
    first_name: teacher_data[:name],
    last_name: teacher_data[:last],
    phone: "(11) #{rand(90000000..99999999)}"
  )
  teachers_school2[teacher_data[:subject]] = teacher
end

puts "✅ #{teachers_school2.count} professores criados para escola 2"

# Create Classrooms for School 2 (Elementary School)
classrooms_school2 = []
['6º Ano A', '6º Ano B', '7º Ano A', '7º Ano B', '8º Ano A', '8º Ano B', '9º Ano A'].each_with_index do |name, index|
  shift = index < 3 ? 'morning' : 'afternoon'
  classroom = Classroom.create!(
    name: name,
    academic_year: Date.current.year,
    shift: shift,
    level: 'elementary_2',
    school: school2
  )
  classrooms_school2 << classroom
end

puts "✅ #{classrooms_school2.count} turmas criadas para escola 2"

# Create Students for School 2
all_students_school2 = []
student_names_2 = [
  'Lucas Ferreira', 'Marina Silva', 'Pedro Henrique', 'Julia Santos', 'Gabriel Costa',
  'Leticia Oliveira', 'Arthur Souza', 'Laura Almeida', 'Miguel Pereira', 'Sophia Lima',
  'Heitor Rodrigues', 'Alice Carvalho', 'Davi Martins', 'Manuela Gomes', 'Lorenzo Barbosa',
  'Giovanna Dias', 'Bernardo Ribeiro', 'Helena Fernandes', 'Theo Araujo', 'Valentina Cruz',
  'Nicolas Rocha', 'Isabella Torres', 'Benjamin Cardoso', 'Aurora Mendes', 'Samuel Monteiro',
  'Elisa Nascimento', 'Joaquim Freitas', 'Maya Cavalcanti', 'Isaac Moura', 'Luna Teixeira'
]

classrooms_school2.each_with_index do |classroom, class_index|
  25.times do |i|
    base_name = student_names_2[i % student_names_2.length]
    first_name, last_name = base_name.split(' ')
    
    student = User.create!(
      email: "#{first_name.downcase}.#{last_name.downcase}.e2.#{class_index+1}.#{i+1}@aluno.santosdumont.edu.br",
      password: 'aluno123',
      password_confirmation: 'aluno123',
      user_type: 'student',
      school: school2,
      classroom: classroom,
      first_name: first_name,
      last_name: "#{last_name} E2#{class_index+1}#{i+1}",
      birth_date: Date.new(2009 + rand(0..3), rand(1..12), rand(1..28)),
      guardian_name: guardian_names[i % guardian_names.length]
    )
    all_students_school2 << student
  end
end

puts "✅ #{all_students_school2.count} alunos criados para escola 2"

# Create Subjects for School 2
subjects_school2_data = [
  { name: 'Matemática', area: 'mathematics', teacher: 'Matemática' },
  { name: 'Língua Portuguesa', area: 'languages', teacher: 'Língua Portuguesa' },
  { name: 'Ciências', area: 'natural_sciences', teacher: 'Ciências' },
  { name: 'História', area: 'human_sciences', teacher: 'História' },
  { name: 'Geografia', area: 'human_sciences', teacher: 'Geografia' },
  { name: 'Inglês', area: 'languages', teacher: 'Inglês' },
  { name: 'Educação Física', area: 'physical_education', teacher: 'Educação Física' },
  { name: 'Artes', area: 'arts', teacher: 'Artes' }
]

all_subjects_school2 = {}
subjects_school2_data.each do |subject_data|
  subject = Subject.create!(
    name: subject_data[:name],
    classroom: nil,
    school: school2,
    user: teachers_school2[subject_data[:teacher]],
    workload: 1,
    area: subject_data[:area],
    code: subject_data[:name].gsub(' ', '')[0..4].upcase,
    description: "Disciplina de #{subject_data[:name]}"
  )
  all_subjects_school2[subject_data[:name]] = subject
end

puts "✅ #{all_subjects_school2.count} disciplinas criadas para escola 2"

# Create Class Schedules for School 2
teacher_schedules_2 = {}
teachers_school2.values.each { |teacher| teacher_schedules_2[teacher.id] = {} }

workload_elementary = {
  'Matemática' => 5, 'Língua Portuguesa' => 5, 'Ciências' => 4,
  'História' => 3, 'Geografia' => 3, 'Inglês' => 2,
  'Educação Física' => 2, 'Artes' => 2
}

classrooms_school2.each do |classroom|
  times = classroom.shift == 'morning' ? morning_times : afternoon_times
  
  subjects_with_slots = []
  workload_elementary.each do |subject_name, slots|
    subject = all_subjects_school2[subject_name]
    next unless subject
    slots.times { subjects_with_slots << subject }
  end
  
  subjects_with_slots.shuffle!
  
  slot_index = 0
  (1..5).each do |weekday|
    times.each_with_index do |time_slot, period|
      break if slot_index >= subjects_with_slots.length
      
      subject = subjects_with_slots[slot_index]
      teacher = subject.user
      time_key = "#{weekday}_#{time_slot[0]}_#{time_slot[1]}"
      
      if teacher_schedules_2[teacher.id][time_key]
        slot_index += 1
        redo if slot_index < subjects_with_slots.length
        next
      end
      
      teacher_schedules_2[teacher.id][time_key] = true
      
      ClassSchedule.create!(
        classroom: classroom,
        subject: subject,
        school: school2,
        weekday: weekday,
        start_time: Time.parse(time_slot[0]),
        end_time: Time.parse(time_slot[1]),
        period: classroom.shift == 'morning' ? 'matutino' : 'vespertino',
        class_order: period + 1,
        active: true
      )
      
      slot_index += 1
    end
  end
end

all_subjects_school2.values.each do |subject|
  total_workload = ClassSchedule.where(subject: subject).count
  subject.update!(workload: [total_workload, 1].max)
end

puts "✅ Horários criados para escola 2"

# Create Grades for School 2
all_subjects_school2.values.each do |subject|
  students = subject.students
  
  students.each do |student|
    rand(3..4).times do |grade_index|
      grade_type = grade_types.sample
      max_value = case grade_type
      when 'prova' then 10.0
      when 'trabalho' then 10.0
      when 'atividade' then 5.0
      when 'participacao' then 3.0
      end
      
      percentage = rand(50..100)
      value = (max_value * percentage / 100.0).round(2)
      assessment_name = "#{assessment_names[grade_type].sample} #{grade_index + 1}"
      
      Grade.create!(
        student: student,
        subject: subject,
        school: school2,
        bimester: 3,
        value: value,
        max_value: max_value,
        grade_type: grade_type,
        assessment_name: assessment_name,
        assessment_date: Date.current - rand(1..60).days,
        teacher_notes: percentage >= 70 ? 'Bom desempenho' : 'Precisa melhorar'
      )
    end
  end
end

puts "✅ Notas criadas para escola 2"

# Create Events for School 2
events_school2 = [
  { title: 'Festa Junina', type: 'cultural', description: 'Festa junina da escola', days_from_now: -90 },
  { title: 'Olimpíada de Matemática', type: 'academico', description: 'Competição de matemática entre alunos', days_from_now: 20 },
  { title: 'Dia da Família', type: 'celebration', description: 'Evento de integração com famílias', days_from_now: 45 }
]

events_school2.each do |event_data|
  event_date = Date.current + event_data[:days_from_now].days
  Event.create!(
    title: event_data[:title],
    description: event_data[:description],
    event_type: event_data[:type],
    start_date: event_date,
    end_date: event_date,
    start_time: Time.parse('08:00'),
    end_time: Time.parse('17:00'),
    school: school2,
    is_municipal: false
  )
end

puts "✅ Eventos criados para escola 2"

puts "\n" + "="*70
puts "🏫 CRIANDO DADOS PARA ESCOLA 3: #{school3.name}"
puts "="*70

# Create Direction for School 3
director3 = User.create!(
  email: 'diretor@ruibarbosa.edu.br',
  password: 'diretor123',
  password_confirmation: 'diretor123',
  user_type: 'direction',
  school: school3,
  first_name: 'Amanda',
  last_name: 'Ribeiro Diretora',
  phone: '(11) 99876-1234'
)

coordinator3 = User.create!(
  email: 'coordenacao@ruibarbosa.edu.br',
  password: 'coord123',
  password_confirmation: 'coord123',
  user_type: 'direction',
  school: school3,
  first_name: 'Ricardo',
  last_name: 'Souza Coordenador',
  phone: '(11) 98321-6547'
)

puts "✅ Direção escola 3 criada"

# Create Teachers for School 3
teachers_school3_data = [
  { name: 'Adriana', last: 'Matemática', email: 'adriana.mat@ruibarbosa.edu.br', subject: 'Matemática' },
  { name: 'Bruno', last: 'Português', email: 'bruno.port@ruibarbosa.edu.br', subject: 'Língua Portuguesa' },
  { name: 'Camila', last: 'Física', email: 'camila.fisica@ruibarbosa.edu.br', subject: 'Física' },
  { name: 'Diego', last: 'Química', email: 'diego.quimica@ruibarbosa.edu.br', subject: 'Química' },
  { name: 'Elaine', last: 'Biologia', email: 'elaine.bio@ruibarbosa.edu.br', subject: 'Biologia' },
  { name: 'Fabio', last: 'História', email: 'fabio.historia@ruibarbosa.edu.br', subject: 'História' },
  { name: 'Gisele', last: 'Geografia', email: 'gisele.geo@ruibarbosa.edu.br', subject: 'Geografia' },
  { name: 'Henrique', last: 'Inglês', email: 'henrique.ingles@ruibarbosa.edu.br', subject: 'Inglês' },
  { name: 'Ivone', last: 'Ed. Física', email: 'ivone.edfisica@ruibarbosa.edu.br', subject: 'Educação Física' },
  { name: 'Jorge', last: 'Filosofia', email: 'jorge.filo@ruibarbosa.edu.br', subject: 'Filosofia' }
]

teachers_school3 = {}
teachers_school3_data.each do |teacher_data|
  teacher = User.create!(
    email: teacher_data[:email],
    password: 'professor123',
    password_confirmation: 'professor123',
    user_type: 'teacher',
    school: school3,
    first_name: teacher_data[:name],
    last_name: teacher_data[:last],
    phone: "(11) #{rand(90000000..99999999)}"
  )
  teachers_school3[teacher_data[:subject]] = teacher
end

puts "✅ #{teachers_school3.count} professores criados para escola 3"

# Create Classrooms for School 3 (High School)
classrooms_school3 = []
['1º Ano A', '1º Ano B', '2º Ano A', '2º Ano B', '3º Ano A', '3º Ano B'].each_with_index do |name, index|
  shift = index < 3 ? 'morning' : 'afternoon'
  classroom = Classroom.create!(
    name: name,
    academic_year: Date.current.year,
    shift: shift,
    level: 'high_school',
    school: school3
  )
  classrooms_school3 << classroom
end

puts "✅ #{classrooms_school3.count} turmas criadas para escola 3"

# Create Students for School 3
all_students_school3 = []
student_names_3 = [
  'Adriano Campos', 'Bianca Moreira', 'Cesar Vieira', 'Daniela Ramos', 'Eduardo Cunha',
  'Francesca Pinto', 'Gustavo Neves', 'Heloisa Batista', 'Igor Correia', 'Jessica Macedo',
  'Kaique Farias', 'Lara Azevedo', 'Murilo Castro', 'Nicole Barros', 'Otavio Sales',
  'Paula Melo', 'Rafael Vasconcelos', 'Sara Nogueira', 'Tiago Rezende', 'Ursula Campos',
  'Vitor Leal', 'Wendy Siqueira', 'Xavier Pacheco', 'Yasmin Amaral', 'Zeca Duarte',
  'Alexandre Braga', 'Barbara Fonseca', 'Caio Evangelista', 'Diana Tavares', 'Erick Miranda'
]

classrooms_school3.each_with_index do |classroom, class_index|
  28.times do |i|
    base_name = student_names_3[i % student_names_3.length]
    first_name, last_name = base_name.split(' ')
    
    student = User.create!(
      email: "#{first_name.downcase}.#{last_name.downcase}.e3.#{class_index+1}.#{i+1}@aluno.ruibarbosa.edu.br",
      password: 'aluno123',
      password_confirmation: 'aluno123',
      user_type: 'student',
      school: school3,
      classroom: classroom,
      first_name: first_name,
      last_name: "#{last_name} E3#{class_index+1}#{i+1}",
      birth_date: Date.new(2006 + rand(0..2), rand(1..12), rand(1..28)),
      guardian_name: guardian_names[i % guardian_names.length]
    )
    all_students_school3 << student
  end
end

puts "✅ #{all_students_school3.count} alunos criados para escola 3"

# Create Subjects for School 3
subjects_school3_data = [
  { name: 'Matemática', area: 'mathematics', teacher: 'Matemática' },
  { name: 'Língua Portuguesa', area: 'languages', teacher: 'Língua Portuguesa' },
  { name: 'Física', area: 'natural_sciences', teacher: 'Física' },
  { name: 'Química', area: 'natural_sciences', teacher: 'Química' },
  { name: 'Biologia', area: 'natural_sciences', teacher: 'Biologia' },
  { name: 'História', area: 'human_sciences', teacher: 'História' },
  { name: 'Geografia', area: 'human_sciences', teacher: 'Geografia' },
  { name: 'Inglês', area: 'languages', teacher: 'Inglês' },
  { name: 'Educação Física', area: 'physical_education', teacher: 'Educação Física' },
  { name: 'Filosofia', area: 'human_sciences', teacher: 'Filosofia' }
]

all_subjects_school3 = {}
subjects_school3_data.each do |subject_data|
  subject = Subject.create!(
    name: subject_data[:name],
    classroom: nil,
    school: school3,
    user: teachers_school3[subject_data[:teacher]],
    workload: 1,
    area: subject_data[:area],
    code: subject_data[:name].gsub(' ', '')[0..4].upcase,
    description: "Disciplina de #{subject_data[:name]}"
  )
  all_subjects_school3[subject_data[:name]] = subject
end

puts "✅ #{all_subjects_school3.count} disciplinas criadas para escola 3"

# Create Class Schedules for School 3
teacher_schedules_3 = {}
teachers_school3.values.each { |teacher| teacher_schedules_3[teacher.id] = {} }

classrooms_school3.each do |classroom|
  times = classroom.shift == 'morning' ? morning_times : afternoon_times
  year_key = classroom.name.split(' ').first
  classroom_workload = workload_per_year[year_key] || workload_per_year['1º Ano']
  
  subjects_with_slots = []
  classroom_workload.each do |subject_name, slots|
    subject = all_subjects_school3[subject_name]
    next unless subject
    slots.times { subjects_with_slots << subject }
  end
  
  subjects_with_slots.shuffle!
  
  slot_index = 0
  (1..5).each do |weekday|
    times.each_with_index do |time_slot, period|
      break if slot_index >= subjects_with_slots.length
      
      subject = subjects_with_slots[slot_index]
      teacher = subject.user
      time_key = "#{weekday}_#{time_slot[0]}_#{time_slot[1]}"
      
      if teacher_schedules_3[teacher.id][time_key]
        slot_index += 1
        redo if slot_index < subjects_with_slots.length
        next
      end
      
      teacher_schedules_3[teacher.id][time_key] = true
      
      ClassSchedule.create!(
        classroom: classroom,
        subject: subject,
        school: school3,
        weekday: weekday,
        start_time: Time.parse(time_slot[0]),
        end_time: Time.parse(time_slot[1]),
        period: classroom.shift == 'morning' ? 'matutino' : 'vespertino',
        class_order: period + 1,
        active: true
      )
      
      slot_index += 1
    end
  end
end

all_subjects_school3.values.each do |subject|
  total_workload = ClassSchedule.where(subject: subject).count
  subject.update!(workload: [total_workload, 1].max)
end

puts "✅ Horários criados para escola 3"

# Create Grades for School 3
all_subjects_school3.values.each do |subject|
  students = subject.students
  
  students.each do |student|
    rand(4..5).times do |grade_index|
      grade_type = grade_types.sample
      max_value = case grade_type
      when 'prova' then 10.0
      when 'trabalho' then 10.0
      when 'atividade' then 5.0
      when 'participacao' then 3.0
      end
      
      percentage = rand(45..98)
      value = (max_value * percentage / 100.0).round(2)
      assessment_name = "#{assessment_names[grade_type].sample} #{grade_index + 1}"
      
      Grade.create!(
        student: student,
        subject: subject,
        school: school3,
        bimester: 3,
        value: value,
        max_value: max_value,
        grade_type: grade_type,
        assessment_name: assessment_name,
        assessment_date: Date.current - rand(1..60).days,
        teacher_notes: percentage >= 70 ? 'Ótimo aproveitamento' : 'Necessita reforço'
      )
    end
  end
end

puts "✅ Notas criadas para escola 3"

# Create Absences for School 3
all_subjects_school3.values.each do |subject|
  students = subject.students
  
  students.sample(students.count * 0.25).each do |student|
    rand(1..4).times do
      is_justified = [true, false].sample
      
      Absence.create!(
        student: student,
        subject: subject,
        date: Date.current - rand(1..90).days,
        justified: is_justified,
        justification: is_justified ? justification_reasons.sample : nil
      )
    end
  end
end

puts "✅ Faltas criadas para escola 3"

# Create Events for School 3
events_school3 = [
  { title: 'Simulado ENEM', type: 'academico', description: 'Simulado preparatório completo', days_from_now: 10 },
  { title: 'Palestra Profissões', type: 'academico', description: 'Palestra sobre escolha de carreira', days_from_now: 25 },
  { title: 'Campeonato de Xadrez', type: 'esportivo', description: 'Torneio interno de xadrez', days_from_now: 35 },
  { title: 'Mostra Cultural', type: 'cultural', description: 'Exposição de trabalhos culturais', days_from_now: -20 }
]

events_school3.each do |event_data|
  event_date = Date.current + event_data[:days_from_now].days
  Event.create!(
    title: event_data[:title],
    description: event_data[:description],
    event_type: event_data[:type],
    start_date: event_date,
    end_date: event_date,
    start_time: Time.parse('08:00'),
    end_time: Time.parse('17:00'),
    school: school3,
    is_municipal: false
  )
end

puts "✅ Eventos criados para escola 3"

# Create Messages between schools staff
teachers_school3.values.sample(5).each do |teacher|
  Message.create!(
    sender: director3,
    recipient: teacher,
    school: school3,
    subject: 'Planejamento Semestral',
    body: 'Por favor, envie seu planejamento semestral até o final da semana.',
    read_at: rand(2) == 0 ? Time.current - rand(1..5).days : nil
  )
end

puts "✅ Mensagens criadas para escola 3"

puts "\n🎯 RESUMO FINAL CONSOLIDADO:"
puts "="*70
puts "👨‍💼 Admins: #{User.admin.count}"
puts "🏫 Escolas: #{School.count}"
puts ""
puts "📊 ESCOLA 1 - #{school1.name}:"
puts "  👥 Direção: 2 (Diretor + Coordenador)"
puts "  👩‍🏫 Professores: #{school1.teachers.count}"
puts "  🏛️ Turmas: #{school1.classrooms.count} (Ensino Médio)"
puts "  👨‍🎓 Alunos: #{school1.students.count}"
puts "  📚 Disciplinas: #{school1.subjects.count}"
puts "  📅 Horários: #{school1.class_schedules.count}"
puts "  📊 Notas: #{school1.grades.count}"
puts "  ❌ Faltas: #{school1.absences.count}"
puts "  📄 Documentos: #{school1.documents.count}"
puts "  🎉 Eventos: #{school1.events.count}"
puts "  💬 Mensagens: #{school1.messages.count}"
puts ""
puts "📊 ESCOLA 2 - #{school2.name}:"
puts "  👥 Direção: 2 (Diretor + Coordenador)"
puts "  👩‍🏫 Professores: #{school2.teachers.count}"
puts "  🏛️ Turmas: #{school2.classrooms.count} (Ensino Fundamental II)"
puts "  👨‍🎓 Alunos: #{school2.students.count}"
puts "  📚 Disciplinas: #{school2.subjects.count}"
puts "  📅 Horários: #{school2.class_schedules.count}"
puts "  📊 Notas: #{school2.grades.count}"
puts "  🎉 Eventos: #{school2.events.count}"
puts ""
puts "📊 ESCOLA 3 - #{school3.name}:"
puts "  👥 Direção: 2 (Diretor + Coordenador)"
puts "  👩‍🏫 Professores: #{school3.teachers.count}"
puts "  🏛️ Turmas: #{school3.classrooms.count} (Ensino Médio)"
puts "  👨‍🎓 Alunos: #{school3.students.count}"
puts "  📚 Disciplinas: #{school3.subjects.count}"
puts "  📅 Horários: #{school3.class_schedules.count}"
puts "  📊 Notas: #{school3.grades.count}"
puts "  ❌ Faltas: #{school3.absences.count}"
puts "  🎉 Eventos: #{school3.events.count}"
puts "  💬 Mensagens: #{school3.messages.count}"
puts ""
puts "="*70
puts "📈 TOTAIS GERAIS DO SISTEMA:"
puts "  👨‍💼 Admins: #{User.admin.count}"
puts "  👥 Direção: #{User.direction.count}"
puts "  👩‍🏫 Professores: #{User.teacher.count}"
puts "  👨‍🎓 Alunos: #{User.student.count}"
puts "  🏫 Escolas: #{School.count}"
puts "  🏛️ Turmas: #{Classroom.count}"
puts "  📚 Disciplinas: #{Subject.count}"
puts "  📅 Horários: #{ClassSchedule.count}"
puts "  📊 Notas: #{Grade.count}"
puts "  ❌ Faltas: #{Absence.count}"
puts "  📄 Documentos: #{Document.count}"
puts "  🎉 Eventos: #{Event.count}"
puts "  💬 Mensagens: #{Message.count}"
puts "="*70
puts "\n✅ SEED CONCLUÍDO COM SUCESSO!"
puts "🔑 Credenciais:"
puts "   Admin: admin@sistema.com / admin2@sistema.com / admin3@sistema.com | senha: 123456"
puts "   Diretor: diretor@[escola].edu.br | senha: diretor123"
puts "   Coordenador: coordenacao@[escola].edu.br | senha: coord123"
puts "   Professor: [nome].[materia]@[escola].edu.br | senha: professor123"
puts "   Aluno: [nome].[sobrenome].[escola]@aluno.[escola].edu.br | senha: aluno123"
