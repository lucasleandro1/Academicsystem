require 'rails_helper'

RSpec.describe Teachers::DashboardController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns necessary instance variables' do
      get :index
      expect(assigns(:teacher)).to eq(teacher)
      expect(assigns(:subjects)).to be_present
      expect(assigns(:my_classrooms)).to be_present
      expect(assigns(:my_subjects)).to be_present
    end
  end
end

RSpec.describe Teachers::ClassroomsController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns classrooms' do
      get :index
      expect(assigns(:classrooms)).to be_present
    end
  end
end

RSpec.describe Teachers::SubjectsController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns subjects' do
      get :index
      expect(assigns(:subjects)).to be_present
    end
  end
end

RSpec.describe Teachers::GradesController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns subjects and grades' do
      get :index
      expect(assigns(:subjects)).to be_present
    end
  end
end

RSpec.describe Teachers::MessagesController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns sent and received messages' do
      get :index
      expect(assigns(:sent_messages)).to be_present
      expect(assigns(:received_messages)).to be_present
    end
  end
end

RSpec.describe Teachers::DocumentsController, type: :controller do
  let(:school) { FactoryBot.create(:school) }
  let(:teacher) { FactoryBot.create(:user, :teacher, school: school) }

  before do
    sign_in teacher
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns documents' do
      get :index
      expect(assigns(:documents)).to be_present
    end
  end
end
