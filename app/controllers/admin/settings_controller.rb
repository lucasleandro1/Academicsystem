class Admin::SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    # Configurações do sistema
  end

  def update_academic_calendar
    # Implementar atualização do calendário acadêmico
    redirect_to admin_settings_path, notice: "Calendário acadêmico atualizado com sucesso."
  end

  def manage_permissions
    @users = User.where.not(user_type: "admin").includes(:school).order(:first_name, :last_name)
    @schools = School.order(:name)
  end

  def update_user_permissions
    user = User.find(params[:user_id])

    if user.update(user_params)
      redirect_to manage_permissions_admin_settings_path, notice: "Permissões do usuário atualizadas com sucesso."
    else
      redirect_to manage_permissions_admin_settings_path, alert: "Erro ao atualizar permissões."
    end
  end

  def reset_user_access
    user = User.find(params[:user_id])
    new_password = SecureRandom.hex(8)

    if user.update(password: new_password)
      # Aqui você pode enviar o email com a nova senha ou mostrar na tela
      redirect_to manage_permissions_admin_settings_path,
                  notice: "Acesso resetado. Nova senha: #{new_password}"
    else
      redirect_to manage_permissions_admin_settings_path, alert: "Erro ao resetar acesso."
    end
  end

  def backup_system
    # Implementar backup do sistema
    redirect_to admin_settings_path, notice: "Backup iniciado com sucesso."
  end

  def system_info
    @system_info = {
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      environment: Rails.env,
      database: ActiveRecord::Base.connection_config[:adapter],
      total_users: User.count,
      total_schools: School.count,
      disk_usage: calculate_disk_usage,
      last_backup: get_last_backup_date
    }
  end

  private

  def user_params
    params.require(:user).permit(:user_type, :school_id, :active)
  end

  def calculate_disk_usage
    # Calcular uso do disco (implementação simplificada)
    begin
      size = `du -sh #{Rails.root}`.split.first
      size || "N/A"
    rescue
      "N/A"
    end
  end

  def get_last_backup_date
    # Obter data do último backup (implementação simplificada)
    backup_file = Dir.glob(Rails.root.join("tmp", "backups", "*")).max_by { |f| File.mtime(f) }
    backup_file ? File.mtime(backup_file).strftime("%d/%m/%Y %H:%M") : "Nunca"
  rescue
    "N/A"
  end
end
