class Submission < ApplicationRecord
  belongs_to :activity
  belongs_to :student, -> { where(user_type: "student") }, class_name: "User", foreign_key: "user_id"
  belongs_to :school
end
