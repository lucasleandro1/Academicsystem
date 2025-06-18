class Activity < ApplicationRecord
  belongs_to :subject
  belongs_to :teacher
  belongs_to :school
end
