# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    sequence(:file_name) { |n| "arquivo_#{n}.pdf" }
    file_path { "/path/to/file" }
    file_size { 1024 }
    school
    association :attachable, factory: :document

    trait :image do
      file_name { "imagem.jpg" }
    end

    trait :document_file do
      file_name { "documento.pdf" }
    end
  end
end
