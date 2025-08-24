class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :show, :mark_as_read, :destroy ]

  def index
    @notifications = current_user.notifications
                                .includes(:sender, :school)
                                .recent
                                .page(params[:page])
                                .per(20)

    @unread_count = current_user.notifications.unread.count
    @notifications_by_type = current_user.notifications
                                        .group(:notification_type)
                                        .count
  end

  def show
    @notification.mark_as_read! unless @notification.read?
  end

  def mark_as_read
    @notification.mark_as_read!
    redirect_back(fallback_location: notifications_path)
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(
      read: true,
      read_at: Time.current
    )
    redirect_to notifications_path, notice: "Todas as notificações foram marcadas como lidas."
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: "Notificação removida com sucesso."
  end

  def clear_all
    current_user.notifications.destroy_all
    redirect_to notifications_path, notice: "Todas as notificações foram removidas."
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
