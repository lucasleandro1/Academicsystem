class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :school, optional: true
  enum :user_type, student: "student", teacher: "teacher", direction: "direction", admin: "admin"

  # Associações como estudante
  has_many :student_enrollments, -> { where(users: { user_type: "student" }) },
           class_name: "Enrollment", foreign_key: "user_id", dependent: :destroy
  has_many :enrolled_classrooms, through: :student_enrollments, source: :classroom
  has_many :student_grades, -> { where(users: { user_type: "student" }) },
           class_name: "Grade", foreign_key: "user_id", dependent: :destroy
  has_many :student_absences, -> { where(users: { user_type: "student" }) },
           class_name: "Absence", foreign_key: "user_id", dependent: :destroy
  has_many :student_submissions, -> { where(users: { user_type: "student" }) },
           class_name: "Submission", foreign_key: "user_id", dependent: :destroy
  has_many :student_documents, -> { where(users: { user_type: "student" }) },
           class_name: "Document", foreign_key: "user_id", dependent: :destroy
  has_many :student_occurrences, -> { where(users: { user_type: "student" }) },
           class_name: "Occurrence", foreign_key: "user_id", dependent: :destroy

  # Associações como professor
  has_many :teacher_subjects, -> { where(users: { user_type: "teacher" }) },
           class_name: "Subject", foreign_key: "user_id", dependent: :destroy
  has_many :teacher_activities, -> { where(users: { user_type: "teacher" }) },
           class_name: "Activity", foreign_key: "user_id", dependent: :destroy
  has_many :teacher_documents, -> { where(users: { user_type: "teacher" }) },
           class_name: "Document", foreign_key: "user_id", dependent: :destroy
  has_many :authored_occurrences, -> { where(users: { user_type: "teacher" }) },
           class_name: "Occurrence", as: :author, dependent: :destroy

  # Mensagens
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id", dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: "recipient_id", dependent: :destroy

  # Aliases para facilitar o uso
  alias_method :enrollments, :student_enrollments
  alias_method :classrooms, :enrolled_classrooms
  alias_method :grades, :student_grades
  alias_method :absences, :student_absences
  alias_method :submissions, :student_submissions
  alias_method :subjects, :teacher_subjects
  alias_method :activities, :teacher_activities

  validates :email, presence: true, uniqueness: true

  with_options if: :teacher? do
    validates :position, presence: true
    validates :specialization, presence: true
  end

  with_options if: :student? do
    validates :birth_date, presence: true
    validates :guardian_name, presence: true
  end

  scope :active, -> { where(active: true) }
  scope :students, -> { where(user_type: "student") }
  scope :teachers, -> { where(user_type: "teacher") }
  scope :directions, -> { where(user_type: "direction") }
  scope :admins, -> { where(user_type: "admin") }

  def full_name
    if first_name.present? || last_name.present?
      "#{first_name} #{last_name}".strip
    else
      email.split("@").first.humanize
    end
  end

  def age
    return nil unless birth_date
    ((Date.current - birth_date) / 365).to_i
  end
end
