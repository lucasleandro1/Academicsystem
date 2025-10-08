require 'rails_helper'

RSpec.describe 'Teachers functionality', type: :feature do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    login_as(teacher, scope: :user)
  end

  context 'Dashboard' do
    it 'allows teacher to access dashboard' do
      visit teachers_root_path
      expect(page).to have_content('Painel do Professor')
      expect(page).to have_content(teacher.full_name)
    end

    it 'displays teacher statistics' do
      visit teachers_root_path
      expect(page).to have_content('Turmas')
      expect(page).to have_content('Disciplinas')
      expect(page).to have_content('Alunos')
    end
  end

  context 'Subjects' do
    let!(:classroom) { FactoryBot.create(:classroom, school: school) }
    let!(:subject) { FactoryBot.create(:subject, user: teacher, classroom: classroom, school: school) }

    it 'displays teacher subjects' do
      visit teachers_subjects_path
      expect(page).to have_content('Minhas Disciplinas')
      expect(page).to have_content(subject.name)
    end
  end

  context 'Classrooms' do
    let!(:classroom) { FactoryBot.create(:classroom, school: school) }
    let!(:subject) { FactoryBot.create(:subject, user: teacher, classroom: classroom, school: school) }

    it 'displays teacher classrooms' do
      visit teachers_classrooms_path
      expect(page).to have_content('Minhas Turmas')
      expect(page).to have_content(classroom.name)
    end
  end

  context 'Grades' do
    it 'allows teacher to access grades page' do
      visit teachers_grades_path
      expect(page).to have_content('Gerenciar Notas')
    end
  end

  context 'Messages' do
    it 'allows teacher to access messages page' do
      visit teachers_messages_path
      expect(page).to have_content('Mensagens')
    end
  end

  context 'Documents' do
    it 'allows teacher to access documents page' do
      visit teachers_documents_path
      expect(page).to have_content('Documentos')
    end
  end

  context 'Reports' do
    it 'allows teacher to access reports page' do
      visit teachers_reports_path
      expect(page).to have_content('Relatórios')
    end
  end

  context 'Class Schedules' do
    it 'allows teacher to access class schedules page' do
      visit teachers_class_schedules_path
      expect(page).to have_content('Grade de Horários')
    end
  end
end
