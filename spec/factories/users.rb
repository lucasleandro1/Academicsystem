# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { |n| "user#{n}@email.com" }
    password { "123456" }
    school

    trait :student do
      user_type { "student" }
    end

    trait :teacher do
      user_type { "teacher" }
    end

    trait :direction do
      user_type { "direction" }
    end

    trait :admin do
      user_type { "admin" }
      school { nil }
    end
  end
end
