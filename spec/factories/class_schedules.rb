# frozen_string_literal: true

FactoryBot.define do
  factory :class_schedule do
    weekday { 1 } # Monday
    start_time { "08:00" }
    end_time { "08:50" }
    classroom
    subject
    school

    before(:create) do |schedule|
      # Garantir que a disciplina pertence à turma
      schedule.subject.classroom = schedule.classroom
      schedule.subject.save! if schedule.subject.changed?
    end

    trait :monday do
      weekday { 1 }
    end

    trait :tuesday do
      weekday { 2 }
    end

    trait :wednesday do
      weekday { 3 }
    end

    trait :thursday do
      weekday { 4 }
    end

    trait :friday do
      weekday { 5 }
    end

    trait :morning_schedule do
      start_time { "08:00" }
      end_time { "08:50" }
    end

    trait :afternoon_schedule do
      start_time { "14:00" }
      end_time { "14:50" }
    end
  end
end
