# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    sequence(:title) { |n| "Evento do Calendário #{n}" }
    date { 1.week.from_now }
    calendar_type { "holiday" }
    all_schools { false }
    school

    trait :municipal do
      all_schools { true }
      school { nil }
    end

    trait :school_specific do
      all_schools { false }
    end

    trait :holiday do
      calendar_type { "holiday" }
    end

    trait :vacation do
      calendar_type { "vacation" }
    end

    trait :meeting do
      calendar_type { "meeting" }
    end
  end
end
