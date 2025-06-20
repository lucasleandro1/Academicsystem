class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :school, optional: true
  has_one :direction
  enum :user_type, student: "student", teacher: "teacher", direction: "direction", admin: "admin"

  validates :email, presence: true, uniqueness: true
end
