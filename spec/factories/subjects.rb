# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:name) { |n| "Matéria #{n}" }
    workload { 40 }
    classroom
    school
    association :user, factory: [ :user, :teacher ]

    # Garantir que o teacher pertença à mesma escola
    before(:create) do |subject|
      if subject.user && subject.school && subject.user.school != subject.school
        subject.user.update!(school: subject.school)
      end
    end

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
