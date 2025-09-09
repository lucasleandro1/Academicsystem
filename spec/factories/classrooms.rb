# frozen_string_literal: true

FactoryBot.define do
  factory :classroom do
    sequence(:name) { |n| "Turma #{n}A" }
    academic_year { Date.current.year }
    shift { :morning }
    level { :high_school }
    school

    trait :afternoon do
      shift { :afternoon }
    end

    trait :evening do
      shift { :evening }
    end

    trait :elementary_1 do
      level { :elementary_1 }
    end

    trait :elementary_2 do
      level { :elementary_2 }
    end
  end
end
