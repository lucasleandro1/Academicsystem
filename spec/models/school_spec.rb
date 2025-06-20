# spec/models/school_spec.rb
require 'rails_helper'

RSpec.describe School, type: :model do
  it "is valid with valid attributes" do
    school = School.new(name: "Escola Teste", cnpj: "12345678900000", address: "Rua A", phone: "87999999999")
    expect(school).to be_valid
  end

  it "is invalid without a name" do
    school = School.new(name: nil)
    expect(school).not_to be_valid
  end
end
