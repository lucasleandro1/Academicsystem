# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with email, password and user_type" do
    school = School.create!(name: "Escola A", cnpj: "111", address: "Rua 1", phone: "8799")
    user = User.new(email: "diretor@teste.com", password: "123456", user_type: "direction", school: school, active: true)
    expect(user).to be_valid
  end

  it "is invalid without email" do
    user = User.new(email: nil)
    expect(user).not_to be_valid
  end
end
