class Subject < ApplicationRecord
  belongs_to :classroom
  belongs_to :teacher, -> { where(user_type: "teacher") }, class_name: "User", foreign_key: "user_id"
  belongs_to :school
end
