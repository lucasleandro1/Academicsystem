# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:school) { create(:school) }
  let(:admin_user) { create(:user, :admin, school: school) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    context "when user is admin" do
      before { sign_in admin_user }

      it "renders new template" do
        get :new
        expect(response).to render_template(:new)
        expect(response).to be_successful
      end
    end
  end
end
