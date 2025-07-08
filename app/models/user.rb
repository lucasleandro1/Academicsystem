class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :school, optional: true
  enum :user_type, student: "student", teacher: "teacher", direction: "direction", admin: "admin"

  validates :email, presence: true, uniqueness: true

  with_options if: :teacher? do
    validates :position, presence: true
    validates :specialization, presence: true
  end

  with_options if: :student? do
    validates :birth_date, presence: true
  end
end
