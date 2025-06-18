class ClassSchedule < ApplicationRecord
  belongs_to :classroom
  belongs_to :subject
  belongs_to :school
end
