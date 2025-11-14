class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_specific_controller

  private

  def redirect_to_specific_controller
    # Redirecionar para o controller específico baseado no tipo de usuário
    redirect_url = case current_user.user_type
    when "admin"
      admin_messages_path
    when "direction"
      direction_messages_path
    when "teacher"
      teachers_messages_path
    when "student"
      students_messages_path
    else
      root_path
    end

    redirect_to redirect_url
  end
end
