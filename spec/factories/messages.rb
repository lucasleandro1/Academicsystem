# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    sequence(:subject) { |n| "Assunto da Mensagem #{n}" }
    body { "Conteúdo da mensagem" }
    read_at { nil }
    school
    association :sender, factory: [ :user, :teacher ]
    association :recipient, factory: [ :user, :student ]

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :unread do
      read_at { nil }
    end
  end
end
