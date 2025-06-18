class Occurrence < ApplicationRecord
  belongs_to :student
  belongs_to :author, polymorphic: true
  belongs_to :school
end
