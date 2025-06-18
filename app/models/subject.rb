class Subject < ApplicationRecord
  belongs_to :classroom
  belongs_to :teacher
  belongs_to :school
end
