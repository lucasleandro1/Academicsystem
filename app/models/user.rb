class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :school, optional: true
  has_one :teacher
  has_one :student
  has_one :direction, dependent: :destroy
  enum :user_type, student: "student", teacher: "teacher", direction: "direction", admin: "admin"

  validates :email, presence: true, uniqueness: true

  after_create :create_association_type

  private

  def create_association_type
    case user_type
    when "direction"
      create_direction!
    when "teacher"
      create_teacher!
    when "student"
      create_student!
    end
  end
end
