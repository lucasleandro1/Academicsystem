class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

    case current_user.user_type
    when "admin"
      redirect_to admin_root_path
    when "direction"
      redirect_to direction_root_path
    when "teacher"
      redirect_to teachers_root_path
    when "student"
      redirect_to students_root_path
    else
      redirect_to new_user_session_path, alert: "Tipo de usuário não reconhecido."
    end
  end

  def authorize_superadmin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def after_sign_in_path_for(resource)
    case resource.user_type
    when "admin"
      admin_root_path
    when "direction"
      direction_root_path
    when "teacher"
      teachers_root_path
    when "student"
      students_root_path
    else
      root_path
    end
  end
end
