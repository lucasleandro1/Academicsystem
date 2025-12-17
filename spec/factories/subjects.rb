# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:name) { |n| "Matéria #{n}" }
    workload { 40 }
    classroom
    school

    before(:create) do |subject|
      # Só criar um teacher se não foi fornecido um
      unless subject.user
        subject.user = create(:user, :teacher, school: subject.school)
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
