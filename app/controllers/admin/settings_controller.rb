class Admin::SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  def index
    # Configurações do sistema
    @system_stats = {
      total_users: User.count,
      total_schools: School.count,
      total_students: User.students.count,
      total_teachers: User.teachers.count,
      disk_usage: calculate_disk_usage,
      database_size: calculate_database_size,
      last_backup: get_last_backup_date,
      system_uptime: get_system_uptime
    }

    @recent_backups = get_recent_backups
    @calendar_settings = get_calendar_settings
  end

  def update_academic_calendar
    calendar_params = params.require(:calendar).permit(:start_date, :end_date, :holidays)

    # Salvar configurações do calendário (você pode criar um modelo Calendar para isso)
    if save_calendar_settings(calendar_params)
      redirect_to admin_settings_path, notice: "Calendário acadêmico atualizado com sucesso."
    else
      redirect_to admin_settings_path, alert: "Erro ao atualizar calendário acadêmico."
    end
  end

  def manage_permissions
    @users = User.where.not(user_type: "admin").includes(:school).order(:first_name, :last_name)
    @schools = School.order(:name)
    @user_types = User.user_types.keys.reject { |type| type == "admin" }
  end

  def update_user_permissions
    user = User.find(params[:user_id])

    if user.update(user_params)
      redirect_to manage_permissions_admin_settings_path, notice: "Permissões do usuário atualizadas com sucesso."
    else
      redirect_to manage_permissions_admin_settings_path, alert: "Erro ao atualizar permissões: #{user.errors.full_messages.join(', ')}"
    end
  end

  def reset_user_access
    user = User.find(params[:user_id])
    new_password = generate_secure_password

    if user.update(password: new_password, password_confirmation: new_password)
      # Log da ação
      log_admin_action("Password reset for user #{user.email}")

      redirect_to manage_permissions_admin_settings_path,
                  notice: "Acesso resetado. Nova senha: #{new_password} (Anote essa senha, ela não será mostrada novamente)"
    else
      redirect_to manage_permissions_admin_settings_path, alert: "Erro ao resetar acesso."
    end
  end

  def backup_system
    begin
      backup_filename = "backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}"
      backup_path = Rails.root.join("tmp", "backups")

      # Criar diretório de backup se não existir
      FileUtils.mkdir_p(backup_path)

      # Backup do banco de dados
      if perform_database_backup(backup_path, backup_filename)
        # Backup dos arquivos
        perform_files_backup(backup_path, backup_filename)

        redirect_to admin_settings_path, notice: "Backup realizado com sucesso: #{backup_filename}"
      else
        redirect_to admin_settings_path, alert: "Erro ao realizar backup do banco de dados."
      end
    rescue => e
      redirect_to admin_settings_path, alert: "Erro ao realizar backup: #{e.message}"
    end
  end

  def system_info
    @system_info = {
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      environment: Rails.env,
      database: ActiveRecord::Base.connection_db_config.adapter,
      total_users: User.count,
      total_schools: School.count,
      disk_usage: calculate_disk_usage,
      database_size: calculate_database_size,
      last_backup: get_last_backup_date,
      server_info: get_server_info
    }
  end

  def security_settings
    @failed_login_attempts = get_failed_login_attempts
    @recent_admin_actions = get_recent_admin_actions
    @active_sessions = get_active_sessions
  end

  private

  def user_params
    params.require(:user).permit(:user_type, :school_id)
  end

  def generate_secure_password
    # Gerar senha segura com letras, números e símbolos
    chars = ("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + [ "!", "@", "#", "$", "%" ]
    (0...12).map { chars.sample }.join
  end

  def save_calendar_settings(calendar_params)
    # Implementar salvamento das configurações do calendário
    # Pode ser salvo em um arquivo de configuração ou tabela do banco
    true
  end

  def get_calendar_settings
    # Obter configurações atuais do calendário
    {
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      holidays: []
    }
  end

  def perform_database_backup(backup_path, backup_filename)
    case ActiveRecord::Base.connection_db_config.adapter
    when "sqlite3"
      database_path = ActiveRecord::Base.connection_db_config.database
      backup_file = backup_path.join("#{backup_filename}.sqlite3")
      FileUtils.cp(database_path, backup_file)
      true
    when "postgresql"
      # Implementar backup PostgreSQL
      database_name = ActiveRecord::Base.connection_db_config.database
      system("pg_dump", database_name, out: "#{backup_path}/#{backup_filename}.sql")
    when "mysql2"
      # Implementar backup MySQL
      database_name = ActiveRecord::Base.connection_db_config.database
      system("mysqldump", database_name, out: "#{backup_path}/#{backup_filename}.sql")
    else
      false
    end
  rescue
    false
  end

  def perform_files_backup(backup_path, backup_filename)
    # Backup dos arquivos importantes (uploads, storage, etc.)
    storage_path = Rails.root.join("storage")
    backup_storage = backup_path.join("#{backup_filename}_storage.tar.gz")

    system("tar", "-czf", backup_storage.to_s, "-C", Rails.root.to_s, "storage") if Dir.exist?(storage_path)
  end

  def calculate_disk_usage
    begin
      size = `du -sh #{Rails.root}`.split.first
      size || "N/A"
    rescue
      "N/A"
    end
  end

  def calculate_database_size
    begin
      case ActiveRecord::Base.connection_db_config.adapter
      when "sqlite3"
        database_path = ActiveRecord::Base.connection_db_config.database
        size_bytes = File.size(database_path)
        format_file_size(size_bytes)
      else
        "N/A"
      end
    rescue
      "N/A"
    end
  end

  def format_file_size(size_bytes)
    units = %w[B KB MB GB TB]
    size = size_bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end

    "#{size.round(2)} #{units[unit_index]}"
  end

  def get_last_backup_date
    backup_path = Rails.root.join("tmp", "backups")
    return "Nunca" unless Dir.exist?(backup_path)

    backup_files = Dir.glob(backup_path.join("*"))
    return "Nunca" if backup_files.empty?

    latest_backup = backup_files.max_by { |f| File.mtime(f) }
    File.mtime(latest_backup).strftime("%d/%m/%Y %H:%M")
  rescue
    "N/A"
  end

  def get_recent_backups
    backup_path = Rails.root.join("tmp", "backups")
    return [] unless Dir.exist?(backup_path)

    Dir.glob(backup_path.join("*")).map do |file|
      {
        name: File.basename(file),
        size: format_file_size(File.size(file)),
        created_at: File.mtime(file)
      }
    end.sort_by { |backup| backup[:created_at] }.reverse.first(10)
  rescue
    []
  end

  def get_system_uptime
    begin
      uptime_seconds = File.read("/proc/uptime").split.first.to_f
      days = (uptime_seconds / 86400).to_i
      hours = ((uptime_seconds % 86400) / 3600).to_i
      minutes = ((uptime_seconds % 3600) / 60).to_i
      "#{days}d #{hours}h #{minutes}m"
    rescue
      "N/A"
    end
  end

  def get_server_info
    {
      hostname: `hostname`.strip,
      os: `uname -s`.strip,
      kernel: `uname -r`.strip,
      architecture: `uname -m`.strip
    }
  rescue
    { hostname: "N/A", os: "N/A", kernel: "N/A", architecture: "N/A" }
  end

  def log_admin_action(action)
    Rails.logger.info "[ADMIN] #{current_user.email} - #{action} at #{Time.current}"
  end

  def get_failed_login_attempts
    # Implementar log de tentativas de login falhadas
    []
  end

  def get_recent_admin_actions
    # Implementar log de ações administrativas
    []
  end

  def get_active_sessions
    # Implementar contagem de sessões ativas
    []
  end
end
