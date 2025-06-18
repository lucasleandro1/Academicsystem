class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :school
end
