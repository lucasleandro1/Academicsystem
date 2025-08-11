class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :school, optional: true
  enum :user_type, student: "student", teacher: "teacher", direction: "direction", admin: "admin"

  # Associações como estudante
  has_many :student_enrollments, class_name: "Enrollment", foreign_key: "user_id", dependent: :destroy
  has_many :enrolled_classrooms, through: :student_enrollments, source: :classroom
  has_many :student_grades, class_name: "Grade", foreign_key: "user_id", dependent: :destroy
  has_many :student_absences, class_name: "Absence", foreign_key: "user_id", dependent: :destroy
  has_many :student_submissions, class_name: "Submission", foreign_key: "user_id", dependent: :destroy
  has_many :student_documents, class_name: "Document", foreign_key: "user_id", dependent: :destroy
  has_many :student_occurrences, class_name: "Occurrence", foreign_key: "user_id", dependent: :destroy

  # Associações como professor
  has_many :teacher_subjects, class_name: "Subject", foreign_key: "user_id", dependent: :destroy
  has_many :teacher_activities, class_name: "Activity", foreign_key: "user_id", dependent: :destroy
  has_many :teacher_documents, class_name: "Document", foreign_key: "user_id", dependent: :destroy
  has_many :authored_occurrences, class_name: "Occurrence", as: :author, dependent: :destroy

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

  # Método para obter turmas do professor através das disciplinas
  def teacher_classrooms
    return Classroom.none unless teacher?
    Classroom.joins(:subjects).where(subjects: { user_id: id }).distinct
  end

  # Métodos para filtrar associações por contexto
  def my_enrollments
    return student_enrollments if student?
    Enrollment.none
  end

  def my_grades
    return student_grades if student?
    Grade.none
  end

  def my_subjects
    return teacher_subjects if teacher?
    Subject.none
  end

  def my_activities
    return teacher_activities if teacher?
    Activity.none
  end

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
