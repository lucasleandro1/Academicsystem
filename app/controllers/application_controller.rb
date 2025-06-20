class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authorize_superadmin!
    unless current_user&.superadmin?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      new_admin_school_path
    else
      root_path
    end
  end
end
