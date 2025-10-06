# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { |n| "user#{n}@email.com" }
    password { "123456" }
    school

    trait :student do
      user_type { :student }
      birth_date { Date.new(2010, 5, 10) }
      guardian_name { "Responsável" }
    end

    trait :teacher do
      user_type { :teacher }
    end

    trait :direction do
      user_type { :direction }
    end

    trait :admin do
      user_type { :admin }
    end
  end
end
