# spec/models/direction_spec.rb
require 'rails_helper'

RSpec.describe Direction, type: :model do
  it "is valid with a user" do
    school = School.create!(name: "Escola B", cnpj: "222", address: "Rua 2", phone: "8888")
    user = User.create!(email: "direcao@escola.com", password: "123456", user_type: "direction", school: school, active: true)
    direction = Direction.new(user: user)
    expect(direction).to be_valid
  end
end
