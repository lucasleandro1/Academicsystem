class School < ApplicationRecord
  has_many :users
  has_many :classrooms
  has_many :activities
  validates :name, :cnpj, :address, :phone, presence: true
end
