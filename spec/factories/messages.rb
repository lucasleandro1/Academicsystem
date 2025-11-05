# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    sequence(:subject) { |n| "Assunto da Mensagem #{n}" }
    body { "Conteúdo da mensagem" }
    read_at { nil }
    school

    # Default: admin pode enviar para qualquer um
    association :sender, factory: [ :user, :admin ]
    association :recipient, factory: [ :user, :teacher ]

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :unread do
      read_at { nil }
    end

    # Mensagem de professor para aluno (válida)
    trait :teacher_to_student do
      transient do
        classroom_ref { nil }
      end

      sender { create(:user, :teacher, school: school) }
      recipient do
        classroom = classroom_ref || create(:classroom, school: school)
        create(:user, :student, school: school, classroom: classroom).tap do |student|
          create(:subject, user: sender, classroom: classroom)
        end
      end
    end

    # Mensagem de aluno para professor (válida)
    trait :student_to_teacher do
      transient do
        classroom_ref { nil }
      end

      recipient { create(:user, :teacher, school: school) }
      sender do
        classroom = classroom_ref || create(:classroom, school: school)
        create(:user, :student, school: school, classroom: classroom).tap do |student|
          create(:subject, user: recipient, classroom: classroom)
        end
      end
    end

    # Mensagem de diretor para qualquer um da escola
    trait :direction_to_user do
      sender { create(:user, :direction, school: school) }
      recipient { create(:user, :teacher, school: school) }
    end
  end
end
