class Document < ApplicationRecord
  belongs_to :student, -> { where(user_type: "student") }, class_name: "User", foreign_key: "user_id"
  belongs_to :teacher, -> { where(user_type: "teacher") }, class_name: "User", foreign_key: "user_id"
  belongs_to :school
end
