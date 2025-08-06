# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create Admin User
admin = User.find_or_create_by(email: 'admin@sistema.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'admin'
  user.admin = true
  user.active = true
  user.first_name = 'Admin'
  user.last_name = 'Sistema'
end

puts "Admin criado: #{admin.email}"

# Create School
school = School.find_or_create_by(name: 'Escola Exemplo') do |s|
  s.cnpj = '12.345.678/0001-90'
  s.address = 'Rua das Flores, 123'
  s.phone = '(11) 1234-5678'
  s.logo = 'escola-logo.png'
end

puts "Escola criada: #{school.name}"

# Create Direction User
direction = User.find_or_create_by(email: 'direcao@escola.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'direction'
  user.school = school
  user.active = true
  user.first_name = 'Maria'
  user.last_name = 'Diretora'
end

puts "Direção criada: #{direction.email}"

# Create Teachers
teacher1 = User.find_or_create_by(email: 'professor1@escola.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'teacher'
  user.school = school
  user.active = true
  user.first_name = 'João'
  user.last_name = 'Professor'
  user.position = 'Professor'
  user.specialization = 'Matemática'
end

teacher2 = User.find_or_create_by(email: 'professor2@escola.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'teacher'
  user.school = school
  user.active = true
  user.first_name = 'Ana'
  user.last_name = 'Professora'
  user.position = 'Professora'
  user.specialization = 'Português'
end

puts "Professores criados: #{teacher1.email}, #{teacher2.email}"

# Create Students
student1 = User.find_or_create_by(email: 'aluno1@escola.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'student'
  user.school = school
  user.active = true
  user.first_name = 'Pedro'
  user.last_name = 'Aluno'
  user.birth_date = Date.new(2005, 1, 15)
  user.guardian_name = 'José da Silva'
  user.registration_number = '2024001'
end

student2 = User.find_or_create_by(email: 'aluno2@escola.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.user_type = 'student'
  user.school = school
  user.active = true
  user.first_name = 'Carla'
  user.last_name = 'Aluna'
  user.birth_date = Date.new(2005, 3, 20)
  user.guardian_name = 'Maria Santos'
  user.registration_number = '2024002'
end

puts "Alunos criados: #{student1.email}, #{student2.email}"

# Create Classrooms
classroom1 = Classroom.find_or_create_by(name: '1º Ano A', school: school) do |c|
  c.academic_year = Date.current.year
  c.shift = 'morning'
  c.level = 'high_school'
end

classroom2 = Classroom.find_or_create_by(name: '2º Ano B', school: school) do |c|
  c.academic_year = Date.current.year
  c.shift = 'afternoon'
  c.level = 'high_school'
end

puts "Turmas criadas: #{classroom1.name}, #{classroom2.name}"

# Create Subjects
subject1 = Subject.find_or_create_by(name: 'Matemática', classroom: classroom1, school: school) do |s|
  s.teacher = teacher1
  s.workload = 80
end

subject2 = Subject.find_or_create_by(name: 'Português', classroom: classroom1, school: school) do |s|
  s.teacher = teacher2
  s.workload = 80
end

puts "Disciplinas criadas: #{subject1.name}, #{subject2.name}"

# Create Enrollments
enrollment1 = Enrollment.find_or_create_by(student: student1, classroom: classroom1) do |e|
  e.status = 'active'
end

enrollment2 = Enrollment.find_or_create_by(student: student2, classroom: classroom1) do |e|
  e.status = 'active'
end

puts "Matrículas criadas para #{enrollment1.student.full_name} e #{enrollment2.student.full_name}"

# Create Activities
activity1 = Activity.find_or_create_by(title: 'Exercícios de Álgebra', subject: subject1) do |a|
  a.description = 'Resolva os exercícios do capítulo 3'
  a.due_date = 1.week.from_now
  a.teacher = teacher1
  a.school = school
end

activity2 = Activity.find_or_create_by(title: 'Redação sobre Literatura', subject: subject2) do |a|
  a.description = 'Escreva uma redação sobre o romantismo'
  a.due_date = 2.weeks.from_now
  a.teacher = teacher2
  a.school = school
end

puts "Atividades criadas: #{activity1.title}, #{activity2.title}"

# Create Grades
Grade.find_or_create_by(user_id: student1.id, subject: subject1, bimester: 1, grade_type: 'prova') do |g|
  g.value = 8.5
end

Grade.find_or_create_by(user_id: student2.id, subject: subject2, bimester: 1, grade_type: 'trabalho') do |g|
  g.value = 9.0
end

puts "Notas criadas"

# Create Events
Event.find_or_create_by(title: 'Feira de Ciências', school: school) do |e|
  e.description = 'Feira anual de ciências da escola'
  e.start_date = 1.month.from_now
  e.end_date = 1.month.from_now + 3.days
  e.visible_to = 'all'
end

puts "Eventos criados"

puts "Seeds executados com sucesso!"
