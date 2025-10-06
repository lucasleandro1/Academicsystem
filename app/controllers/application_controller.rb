class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

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
    Rails.logger.info "REDIRECT DEBUG: User type is #{resource.user_type}"

    case resource.user_type
    when "admin"
      Rails.logger.info "REDIRECT DEBUG: Redirecting to admin_root_path"
      admin_root_path
    when "direction"
      Rails.logger.info "REDIRECT DEBUG: Redirecting to direction_root_path"
      direction_root_path
    when "teacher"
      Rails.logger.info "REDIRECT DEBUG: Redirecting to teachers_root_path"
      teachers_root_path
    when "student"
      Rails.logger.info "REDIRECT DEBUG: Redirecting to students_root_path"
      students_root_path
    else
      Rails.logger.info "REDIRECT DEBUG: Unknown user type, redirecting to root_path"
      root_path
    end
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
      return
    end

    unless current_user.school
      redirect_to root_path, alert: "Usuário não possui escola associada. Entre em contato com o administrador."
      nil
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :user_type, :school_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone, :birth_date, :address ])
  end
end
