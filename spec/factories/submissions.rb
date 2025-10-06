# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    answer { "Resposta da atividade" }
    submission_date { Time.current }
    activity
    school

    before(:create) do |submission|
      # Garantir que o student está na mesma turma da disciplina da atividade
      classroom = submission.activity.subject.classroom
      student = create(:user, :student, classroom: classroom, school: submission.activity.subject.school)
      submission.student = student
    end

    trait :graded do
      teacher_grade { 8.5 }
    end

    trait :ungraded do
      teacher_grade { nil }
    end

    trait :late_submission do
      submission_date { 2.days.from_now }
    end
  end
end
