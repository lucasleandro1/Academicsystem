# frozen_string_literal: true

FactoryBot.define do
  factory :absence do
    date { Date.current }
    justified { false }
    subject
    
    before(:create) do |absence|
      # Criar um estudante e uma turma se não existirem
      classroom = absence.subject.classroom
      student = create(:user, :student, classroom: classroom, school: absence.subject.school)
      absence.student = student
    end

    trait :justified do
      justified { true }
    end

    trait :unjustified do
      justified { false }
    end

    trait :past_date do
      date { 1.week.ago }
    end
  end
end
