class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authorize_superadmin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      new_admin_school_path
    elsif resource.direction?
      new_direction_teacher_path
    else
      new_user_session_path
    end
  end
end
