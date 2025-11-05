# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/messages").to route_to("messages#index")
    end

    it "routes to #new" do
      expect(get: "/messages/new").to route_to("messages#new")
    end

    it "routes to #create" do
      expect(post: "/messages").to route_to("messages#create")
    end
  end

  describe "authentication" do
    it "redirects to login when user is not authenticated" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
