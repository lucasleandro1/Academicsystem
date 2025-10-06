namespace :sample_data do
  desc "Create sample data for testing the dashboard"
  task create: :environment do
    puts "Creating sample data..."

    # Buscar escola e usuários existentes
    school = School.first
    if school.nil?
      puts "No school found. Please create a school first."
      exit
    end

    students = User.where(school: school, user_type: "student")
    teachers = User.where(school: school, user_type: "teacher")
    subjects = Subject.joins(:classroom).where(classrooms: { school_id: school.id })

    if students.empty? || teachers.empty? || subjects.empty?
      puts "Not enough data found. Need students, teachers and subjects."
      puts "Students: #{students.count}, Teachers: #{teachers.count}, Subjects: #{subjects.count}"
      exit
    end

    # Criar algumas notas de exemplo
    puts "Creating sample grades..."
    students.each do |student|
      subjects.each do |subject|
        # Verificar se o aluno pertence à turma da disciplina
        next unless student.classroom_id == subject.classroom_id

        # Criar notas para diferentes bimestres
        [ 1, 2, 3, 4 ].each do |bimester|
          # Criar algumas notas por bimestre
          [ "Prova 1", "Trabalho 1", "Atividade 1" ].each_with_index do |assessment, index|
            Grade.find_or_create_by(
              student: student,
              subject: subject,
              school: school,
              bimester: bimester,
              grade_type: [ "prova", "trabalho", "atividade" ][index],
              assessment_name: assessment,
              assessment_date: (30 - (bimester * 5) - index).days.ago
            ) do |grade|
              grade.value = rand(5.0..10.0).round(1) # Nota entre 5.0 e 10.0
              grade.max_value = 10.0
            end
          end
        end
      end
    end

    # Criar algumas faltas de exemplo
    puts "Creating sample absences..."
    students.each do |student|
      subjects.where(classroom_id: student.classroom_id).each do |subject|
        # Criar algumas faltas aleatórias nos últimos 30 dias
        rand(0..3).times do |i|
          Absence.find_or_create_by(
            student: student,
            subject: subject,
            date: rand(1..30).days.ago.to_date
          ) do |absence|
            absence.justified = [ true, false ].sample
          end
        end
      end
    end

    # Criar algumas mensagens de exemplo
    puts "Creating sample messages..."
    all_users = User.where(school: school)

    10.times do
      sender = all_users.sample
      recipient = all_users.where.not(id: sender.id).sample

      next if recipient.nil?

      created_at = rand(1..30).days.ago
      Message.find_or_create_by(
        sender: sender,
        recipient: recipient,
        school: school,
        created_at: created_at
      ) do |message|
        message.subject = [ "Reunião", "Informações", "Aviso", "Comunicado" ].sample
        message.body = "Mensagem de exemplo enviada em #{created_at.strftime('%d/%m/%Y')}"
        message.read_at = [ true, false ].sample ? created_at + rand(1..5).hours : nil
      end
    end

    # Criar grade de horários para as turmas
    puts "Creating class schedules..."
    classrooms = Classroom.where(school: school)

    classrooms.each do |classroom|
      # Buscar disciplinas da turma
      classroom_subjects = Subject.where(classroom: classroom, school: school).includes(:user)
      next if classroom_subjects.empty?

      # Horários padrão (manhã)
      time_slots = [
        { start: "07:00", end: "07:50" },  # 1ª aula
        { start: "07:50", end: "08:40" },  # 2ª aula
        { start: "09:00", end: "09:50" },  # 3ª aula (após intervalo)
        { start: "09:50", end: "10:40" },  # 4ª aula
        { start: "10:40", end: "11:30" }   # 5ª aula
      ]

      # Distribuir disciplinas ao longo da semana (segunda a sexta)
      (1..5).each do |weekday| # 1=Segunda, 2=Terça, ..., 5=Sexta
        time_slots.each_with_index do |slot, slot_index|
          # Distribuir disciplinas de forma rotativa
          subject = classroom_subjects[slot_index % classroom_subjects.size]

          ClassSchedule.find_or_create_by(
            classroom: classroom,
            subject: subject,
            school: school,
            weekday: weekday,
            start_time: slot[:start],
            end_time: slot[:end]
          ) do |schedule|
            schedule.period = "matutino"
            schedule.class_order = slot_index + 1
            schedule.active = true
          end
        end
      end
    end

    # Criar alguns eventos de exemplo
    puts "Creating sample events..."
    3.times do |i|
      event_date = (i * 10 + 5).days.from_now.to_date
      Event.find_or_create_by(
        title: [ "Reunião de Pais", "Festa Junina", "Formatura" ][i],
        school: school,
        start_date: event_date,
        event_date: event_date
      ) do |event|
        event.end_date = event.start_date
        event.description = "Evento de exemplo #{i + 1} na escola #{school.name}"
        event.event_type = [ "reunião", "festa", "formatura" ][i]
        event.start_time = "14:00"
        event.end_time = "17:00"
      end
    end

    puts "Sample data created successfully!"
    puts "Summary:"
    puts "- Grades: #{Grade.count}"
    puts "- Absences: #{Absence.count}"
    puts "- Messages: #{Message.count}"
    puts "- Events: #{Event.count}"
    puts "- Class Schedules: #{ClassSchedule.count}"
  end

  desc "Remove all sample data"
  task remove: :environment do
    puts "Removing sample data..."

    Grade.destroy_all
    Absence.destroy_all
    Message.destroy_all
    Event.destroy_all
    ClassSchedule.destroy_all

    puts "Sample data removed!"
  end
end
