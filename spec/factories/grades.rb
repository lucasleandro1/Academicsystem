# frozen_string_literal: true

FactoryBot.define do
  factory :grade do
    value { 8.5 }
    bimester { 1 }
    grade_type { :prova }
    subject
    
    before(:create) do |grade|
      # Criar um estudante na mesma turma da disciplina
      classroom = grade.subject.classroom
      student = create(:user, :student, classroom: classroom, school: grade.subject.school)
      grade.student = student
    end

    trait :first_bimester do
      bimester { 1 }
    end

    trait :second_bimester do
      bimester { 2 }
    end

    trait :third_bimester do
      bimester { 3 }
    end

    trait :fourth_bimester do
      bimester { 4 }
    end

    trait :exam do
      grade_type { :prova }
    end

    trait :homework do
      grade_type { :trabalho }
    end

    trait :activity do
      grade_type { :atividade }
    end

    trait :participation do
      grade_type { :participacao }
    end

    trait :project do
      grade_type { :projeto }
    end

    trait :low_grade do
      value { 4.0 }
    end

    trait :high_grade do
      value { 9.5 }
    end
  end
end
