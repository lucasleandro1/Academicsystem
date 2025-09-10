# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:name) { |n| "Matéria #{n}" }
    workload { 40 }
    classroom
    school
    association :teacher, factory: [ :user, :teacher ]

    trait :with_high_workload do
      workload { 80 }
    end

    trait :mathematics do
      name { "Matemática" }
    end

    trait :portuguese do
      name { "Português" }
    end
  end
end
