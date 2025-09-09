# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    sequence(:title) { |n| "Atividade #{n}" }
    description { "Descrição da atividade" }
    due_date { 1.week.from_now }
    subject
    school
    
    before(:create) do |activity|
      # Garantir que o teacher da activity seja o mesmo teacher da subject
      activity.teacher = activity.subject.teacher
    end

    trait :with_past_due_date do
      due_date { 1.week.ago }
    end

    trait :with_near_due_date do
      due_date { 2.days.from_now }
    end

    trait :mathematics_activity do
      title { "Exercícios de Matemática" }
      description { "Resolva os exercícios do capítulo 5" }
    end
  end
end
