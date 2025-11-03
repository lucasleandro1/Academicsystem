class Document < ApplicationRecord
  belongs_to :school
  belongs_to :user
  belongs_to :subject, optional: true
  belongs_to :classroom, optional: true

  has_one_attached :attachment

  validates :title, presence: true
  validates :document_type, presence: true
  validates :sharing_type, inclusion: { in: %w[all_students specific_student specific_classroom all_subject_students] }

  scope :municipal, -> { where(is_municipal: true) }
  scope :school_specific, -> { where(is_municipal: [ false, nil ]) }
  scope :by_type, ->(type) { where(document_type: type) }

  DOCUMENT_TYPES = [
    "boletim",
    "historico",
    "ocorrencia",
    "comunicado",
    "regulamento",
    "circular",
    "ata",
    "certificado",
    "declaracao",
    "outros"
  ].freeze

  def municipal?
    is_municipal == true
  end

  def file_exists?
    attachment.attached? || (file_path.present? && File.exist?(file_path))
  end

  def uploader
    user
  end

  def file_size
    if attachment.attached?
      attachment.blob.byte_size
    elsif file_path.present? && File.exist?(file_path)
      File.size(file_path)
    else
      0
    end
  end

  def file_size_humanized
    number_to_human_size(file_size)
  end

  def file_type
    if attachment.attached?
      attachment.filename.extension_with_delimiter.downcase.gsub(".", "")
    elsif file_path.present?
      File.extname(file_path).downcase.gsub(".", "")
    else
      "unknown"
    end
  end

  def type_description
    case document_type
    when "boletim" then "Boletim"
    when "historico" then "Histórico Escolar"
    when "comunicado" then "Comunicado"
    when "regulamento" then "Regulamento"
    when "circular" then "Circular"
    when "ata" then "Ata"
    when "certificado" then "Certificado"
    when "declaracao" then "Declaração"
    when "outros" then "Outros"
    else document_type.humanize
    end
  end

  def sharing_description
    case sharing_type
    when "all_students" then "Todos os alunos da escola"
    when "specific_student" then user_id.present? ? "Aluno específico" : "Não definido"
    when "specific_classroom" then classroom.present? ? "Turma: #{classroom.name}" : "Turma não definida"
    when "all_subject_students" then subject.present? ? "Todos os alunos da disciplina #{subject.name}" : "Disciplina não definida"
    else "Não definido"
    end
  end

  def shared_with_student?(student)
    case sharing_type
    when "all_students" then true
    when "specific_student" then user_id == student.id
    when "specific_classroom" then classroom_id == student.classroom_id
    when "all_subject_students" then subject.present? && subject.classroom_id == student.classroom_id
    else false
    end
  end

  private

  def number_to_human_size(size)
    units = %w[B KB MB GB TB]
    unit = 0
    while size >= 1024 && unit < units.length - 1
      size /= 1024.0
      unit += 1
    end
    "#{size.round(1)} #{units[unit]}"
  end
end
