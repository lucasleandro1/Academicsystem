# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "Evento #{n}" }
    description { "Descrição do evento" }
    event_date { 1.week.from_now }
    is_municipal { false }
    school

    trait :municipal do
      is_municipal { true }
    end

    trait :school_specific do
      is_municipal { false }
    end

    trait :past_event do
      event_date { 1.week.ago }
    end

    trait :upcoming_event do
      event_date { 1.month.from_now }
    end
  end
end
