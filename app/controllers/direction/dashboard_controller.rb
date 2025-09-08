class Direction::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school

    # Estatísticas básicas
    @total_students = User.where(school_id: @school.id, user_type: "student")
                         .distinct.count
    @total_teachers = User.where(school_id: @school.id, user_type: "teacher", active: true).count
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
    @total_activities = calculate_total_activities
    @total_messages = calculate_total_messages

    # Alertas e avisos
    @alerts = generate_school_alerts
  end

  private

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
    teachers_without_subjects = User.where(school_id: @school.id, user_type: "teacher", active: true)
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
    # Como ClassSchedule pode não ter campo date, vamos usar uma abordagem diferente
    total_students = User.where(school_id: @school.id, user_type: "student")
                        .count

    return 0 if total_students.zero?

    total_absences = Absence.joins(:student)
                           .where(users: { school_id: @school.id })
                           .where("absences.date >= ?", 30.days.ago)
                           .count

    # Calculamos uma estimativa simples de presença
    return 95.0 if total_absences.zero?

    attendance_rate = [ 100.0 - (total_absences.to_f / total_students * 10), 0 ].max
    attendance_rate.round(1)
  end

  def calculate_average_grade
    grades = Grade.joins(:student)
                  .where(users: { school_id: @school.id })
                  .where("grades.created_at >= ?", 30.days.ago)

    return "0.0" if grades.empty?

    (grades.average(:value) || 0).round(1).to_s
  end

  def calculate_total_activities
    Activity.where(school_id: @school.id).count
  end

  def calculate_total_messages
    Message.where(sender: current_user)
           .where("created_at >= ?", 30.days.ago)
           .count
  end
end
