class Direction::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school
    load_dashboard_data
  rescue => e
    Rails.logger.error "Erro no dashboard da direção: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    handle_dashboard_error
  end

  def refresh_data
    @school = current_user.school
    load_dashboard_data

    render json: {
      total_students: @total_students,
      total_teachers: @total_teachers,
      total_classrooms: @total_classrooms,
      total_subjects: @total_subjects,
      attendance_rate: @attendance_rate,
      average_grade: @average_grade,
      total_messages: @total_messages,
      updated_at: Time.current.strftime("%d/%m/%Y às %H:%M")
    }
  rescue => e
    Rails.logger.error "Erro ao atualizar dados do dashboard: #{e.message}"
    render json: { error: "Erro ao atualizar dados" }, status: 500
  end

  private

  def load_dashboard_data
    # Estatísticas básicas
    @total_students = User.where(school_id: @school.id, user_type: "student")
                         .distinct.count
    @total_teachers = User.where(school_id: @school.id, user_type: "teacher").count
    @total_classrooms = Classroom.where(school_id: @school.id).count
    @total_subjects = Subject.joins(:classroom).where(classrooms: { school_id: @school.id }).distinct.count

    # Eventos próximos (próximos 7 dias)
    @upcoming_events = Event.where(school_id: @school.id)
                           .where("start_date >= ? AND start_date <= ?", Date.current, 7.days.from_now)
                           .order(:start_date)
                           .limit(5)

    # Avisos e notificações importantes
    @important_notifications = get_important_notifications

    # Relatórios gerais
    @attendance_rate = calculate_attendance_rate
    @average_grade = calculate_average_grade
    @total_messages = calculate_total_messages

    # Alertas e avisos
    @alerts = generate_school_alerts
  end

  def handle_dashboard_error
    # Valores padrão em caso de erro
    @total_students = 0
    @total_teachers = 0
    @total_classrooms = 0
    @total_subjects = 0
    @upcoming_events = []
    @important_notifications = []
    @attendance_rate = 0
    @average_grade = "0.0"
    @total_messages = 0
    @alerts = []

    flash.now[:alert] = "Erro ao carregar dados do dashboard. Alguns indicadores podem não estar atualizados."
  end

  # ... métodos privados existentes ...

  def get_important_notifications
    notifications = []

    # Verificar eventos próximos
    events_today = Event.where(school_id: @school.id, start_date: Date.current).count
    if events_today > 0
      notifications << {
        type: "info",
        icon: "fas fa-calendar-day",
        title: "Eventos Hoje",
        message: "#{events_today} evento(s) programado(s) para hoje",
        link: direction_events_path
      }
    end

    # Verificar professores sem disciplinas
    teachers_without_subjects = User.where(school_id: @school.id, user_type: "teacher")
                                   .left_joins(:teacher_subjects)
                                   .where(subjects: { id: nil })
                                   .count
    if teachers_without_subjects > 0
      notifications << {
        type: "warning",
        icon: "fas fa-user-times",
        title: "Professores sem Disciplinas",
        message: "#{teachers_without_subjects} professor(es) sem disciplinas atribuídas",
        link: direction_teachers_path
      }
    end

    notifications
  end

  def generate_school_alerts
    alerts = []

    # Taxa de frequência baixa
    if @attendance_rate < 75
      alerts << {
        type: "danger",
        title: "Taxa de Frequência Baixa",
        message: "A taxa de frequência da escola está em #{@attendance_rate}%, abaixo do recomendado (85%)"
      }
    end

    # Turmas sem professores
    classrooms_without_teachers = Classroom.where(school_id: @school.id)
                                          .left_joins(:subjects)
                                          .where(subjects: { id: nil })
                                          .count
    if classrooms_without_teachers > 0
      alerts << {
        type: "warning",
        title: "Turmas sem Professores",
        message: "#{classrooms_without_teachers} turma(s) sem professores atribuídos"
      }
    end

    alerts
  end

  private

  def calculate_attendance_rate
    # Calculando taxa de frequência baseada nas ausências dos últimos 30 dias
    total_students = User.where(school_id: @school.id, user_type: "student").count

    return 95.0 if total_students.zero?

    total_absences = Absence.joins(:student)
                           .where(users: { school_id: @school.id })
                           .where("absences.date >= ?", 30.days.ago)
                           .count

    # Se não há ausências, consideramos 95% de frequência como padrão
    return 95.0 if total_absences.zero?

    # Calculamos uma estimativa baseada nas ausências
    # Assumindo que cada aluno deveria ter pelo menos 20 presenças no mês
    expected_presences = total_students * 20
    actual_presences = expected_presences - total_absences

    attendance_rate = (actual_presences.to_f / expected_presences * 100).round(1)
    [ attendance_rate, 0.0 ].max
  end

  def calculate_average_grade
    grades = Grade.joins(:student)
                  .where(users: { school_id: @school.id })
                  .where("grades.created_at >= ?", 30.days.ago)

    return "0.0" if grades.empty?

    (grades.average(:value) || 0).round(1).to_s
  end

  def calculate_total_messages
    # Contando mensagens enviadas pelos usuários da escola nos últimos 30 dias
    Message.joins(:sender)
           .where(users: { school_id: @school.id })
           .where("messages.created_at >= ?", 30.days.ago)
           .count
  end
end
