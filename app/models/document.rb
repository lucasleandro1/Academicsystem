class Document < ApplicationRecord
  belongs_to :student
  belongs_to :teacher
  belongs_to :school
end
