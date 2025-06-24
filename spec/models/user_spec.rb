# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe "enum user_type" do
    it "aceita tipos válidos" do
      expect(build(:user, user_type: :student).student?).to be true
      expect(build(:user, user_type: :teacher).teacher?).to be true
      expect(build(:user, user_type: :direction).direction?).to be true
      expect(build(:user, user_type: :admin).admin?).to be true
    end
  end

  describe "atributos específicos por tipo de usuário" do
    it "atributos de professor" do
      user = create(:user, user_type: :teacher, position: "Coordenador", specialization: "Matemática")
      expect(user.position).to eq("Coordenador")
      expect(user.specialization).to eq("Matemática")
    end

    it "atributos de aluno" do
      user = create(:user, user_type: :student, registration_number: "123", birth_date: Date.new(2010, 1, 1), guardian_name: "Pai")
      expect(user.registration_number).to eq("123")
      expect(user.guardian_name).to eq("Pai")
    end
  end
end
