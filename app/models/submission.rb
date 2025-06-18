class Submission < ApplicationRecord
  belongs_to :activity
  belongs_to :student
  belongs_to :school
end
