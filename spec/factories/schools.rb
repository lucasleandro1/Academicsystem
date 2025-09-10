# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    sequence(:name) { |n| "Escola #{n}" }
    sequence(:cnpj) { |n| "#{n.to_s.rjust(11, '0')}0001#{sprintf('%02d', n % 100)}" }
    address { "Rua ABC" }
    phone { "11999999999" }
    logo { " " }
  end
end
