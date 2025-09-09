class Document < ApplicationRecord
  belongs_to :school
  belongs_to :user

  validates :title, presence: true
  validates :document_type, presence: true

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
    file_path.present? && File.exist?(file_path) if file_path.present?
  end

  def uploader
    user
  end

  def file_size
    return 0 unless file_exists?
    File.size(file_path)
  end

  def file_size_humanized
    number_to_human_size(file_size)
  end

  def type_description
    case document_type
    when "boletim" then "Boletim"
    when "historico" then "Histórico Escolar"
    when "ocorrencia" then "Ocorrência"
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
