class Subject < ApplicationRecord
  belongs_to :classroom, optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
  belongs_to :school

  has_many :grades, dependent: :destroy
  has_many :absences, dependent: :destroy
  has_many :class_schedules, dependent: :destroy

  validates :name, :workload, presence: true
  validates :name, uniqueness: { scope: [ :school_id ] }
  validates :workload, numericality: { greater_than: 0 }
  validates :code, uniqueness: { scope: :school_id }, allow_blank: true
  validates :area, inclusion: {
    in: %w[languages mathematics natural_sciences human_sciences religious_education physical_education arts technology],
    allow_blank: true
  }
  validate :teacher_must_be_teacher

  scope :by_teacher, ->(teacher) { where(user_id: teacher.id) }
  scope :by_classroom, ->(classroom) { where(classroom: classroom) }
  scope :by_area, ->(area) { where(area: area) }

  def teacher
    user
  end

  def students
    # Se tem classroom direto, usar os alunos dessa turma
    if classroom.present?
      classroom.students
    else
      # Se não tem classroom, buscar através dos horários (class_schedules)
      classrooms_from_schedules = class_schedules.joins(:classroom).includes(:classroom).map(&:classroom).uniq

      if classrooms_from_schedules.any?
        # Combinar alunos de todas as turmas que têm horários desta disciplina
        User.student.where(classroom: classrooms_from_schedules)
      else
        User.none
      end
    end
  end

  def available_classrooms
    # Retorna todas as turmas disponíveis para esta disciplina
    classrooms = []

    # Adicionar turma direta se existir
    classrooms << classroom if classroom.present?

    # Adicionar turmas via horários
    classrooms_from_schedules = class_schedules.joins(:classroom).includes(:classroom).map(&:classroom).uniq
    classrooms.concat(classrooms_from_schedules)

    classrooms.uniq
  end

  def students_from_classroom(classroom_id)
    # Retorna alunos de uma turma específica
    User.student.where(classroom_id: classroom_id)
  end

  def average_grade_by_bimester(bimester)
    grades.where(bimester: bimester).average(:value)&.round(2)
  end

  def overall_average
    grades.average(:value)&.round(2)
  end

  def attendance_rate
    return 100.0 if students.empty?

    total_possible_attendances = students.count * workload
    return 100.0 if total_possible_attendances.zero?

    total_absences = absences.count
    ((total_possible_attendances - total_absences).to_f / total_possible_attendances * 100).round(2)
  end

  def weekly_schedule
    class_schedules.order(:weekday, :start_time)
  end

  def schedule_summary
    class_schedules.group(:weekday).count
  end

  def classroom_name
    if classroom.present?
      classroom.name
    else
      # Buscar nomes das turmas através dos horários
      classroom_names = class_schedules.joins(:classroom).pluck("classrooms.name").uniq
      if classroom_names.any?
        classroom_names.join(", ")
      else
        "Não atribuída"
      end
    end
  end

  private

  def teacher_must_be_teacher
    return if user_id.blank?

    user_record = User.find_by(id: user_id)
    return errors.add(:user_id, "não encontrado") unless user_record

    unless user_record.teacher?
      return errors.add(:user_id, "deve ser um professor")
    end

    unless user_record.school_id == school_id
      errors.add(:user_id, "deve ser um professor desta escola")
    end
  end
end
