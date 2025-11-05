# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:school) { create(:school) }
  let(:classroom) { create(:classroom, school: school) }
  let(:admin) { create(:user, :admin, school: school) }
  let(:director) { create(:user, :direction, school: school) }
  let(:teacher) { create(:user, :teacher, school: school) }
  let(:student) { create(:user, :student, school: school, classroom: classroom) }

  describe "without authentication" do
    it "redirects to login" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "with authentication using warden" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      login_user(admin)
    end

    it "allows authenticated access" do
      get :index
      expect(response).to be_successful
    end
  end

  def login_user(user)
    @request.env['warden'] = double(Warden, authenticate: user, user: user, authenticate!: user)
  end
end
