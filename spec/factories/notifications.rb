# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    sequence(:title) { |n| "Notificação #{n}" }
    content { "Conteúdo da notificação" }
    notification_type { "grade_posted" }
    read { false }
    user
    association :sender, factory: [ :user, :admin ]
    school { user.school }

    trait :read do
      read { true }
    end

    trait :unread do
      read { false }
    end

    trait :grade_posted do
      notification_type { "grade_posted" }
    end

    trait :activity_assigned do
      notification_type { "activity_assigned" }
    end

    trait :message_received do
      notification_type { "message_received" }
    end

    trait :system_maintenance do
      notification_type { "system_maintenance" }
    end
  end
end
