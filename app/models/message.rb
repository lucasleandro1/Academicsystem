class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :school

  validates :subject, :body, presence: true
  validates :sender_id, :recipient_id, presence: true
  validate :recipient_is_authorized

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  private

  def recipient_is_authorized
    return unless sender && recipient_id

    service = MessageRecipientService.new(sender)

    unless service.can_send_to?(recipient_id)
      errors.add(:recipient_id, "não é um destinatário autorizado para seu tipo de usuário")
    end
  end
end
