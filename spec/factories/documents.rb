# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    sequence(:title) { |n| "Documento #{n}" }
    document_type { "comunicado" }
    is_municipal { false }
    school
    association :user, factory: [:user, :direction]

    trait :municipal do
      is_municipal { true }
    end

    trait :school_specific do
      is_municipal { false }
    end

    trait :bulletin do
      document_type { "boletim" }
    end

    trait :certificate do
      document_type { "certificado" }
    end

    trait :announcement do
      document_type { "comunicado" }
    end

    trait :with_uploader do
      association :user, factory: [ :user, :teacher ]
    end
  end
end
