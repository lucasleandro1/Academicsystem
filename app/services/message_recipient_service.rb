class MessageRecipientService
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  # Retorna destinatários organizados por categoria para select agrupado
  def available_recipients_grouped
    case current_user.user_type
    when "admin"
      admin_recipients_grouped
    when "direction"
      direction_recipients_grouped
    when "teacher"
      teacher_recipients_grouped
    when "student"
      student_recipients_grouped
    else
      {}
    end
  end

  # Retorna lista simples de destinatários autorizados
  def available_recipients_list
    recipients = available_recipients_grouped
    recipients.values.flatten.uniq
  end

  # Verifica se um destinatário é válido para o usuário atual
  def can_send_to?(recipient_id)
    return false unless recipient_id.present?

    recipient_id = recipient_id.to_i
    return false if recipient_id == current_user.id

    case current_user.user_type
    when "admin"
      # Admin pode enviar para qualquer usuário exceto ele mesmo
      User.where(id: recipient_id).where.not(id: current_user.id).exists?
    when "direction"
      # Direção pode enviar para usuários de sua escola
      current_user.school.users.where(id: recipient_id).where.not(id: current_user.id).exists?
    when "teacher"
      # Professor pode enviar para direção, alunos de suas turmas e outros professores
      # Usar teacher_classrooms que considera os horários
      classroom_ids = current_user.teacher_classrooms.pluck(:id).uniq
      student_ids = User.where(classroom_id: classroom_ids, user_type: "student").pluck(:id)
      direction_ids = current_user.school.directions.pluck(:id)
      teacher_ids = current_user.school.teachers.where.not(id: current_user.id).pluck(:id)

      (student_ids + direction_ids + teacher_ids).include?(recipient_id)
    when "student"
      # Aluno pode enviar para professores de suas matérias e direção
      return false unless current_user.classroom

      teacher_ids = current_user.classroom.subjects.pluck(:user_id)
      direction_ids = current_user.school.directions.pluck(:id)

      (teacher_ids + direction_ids).include?(recipient_id)
    else
      false
    end
  end

  # Retorna opções de envio em massa disponíveis para o usuário
  def broadcast_options
    case current_user.user_type
    when "admin"
      admin_broadcast_options
    when "direction"
      direction_broadcast_options
    when "teacher"
      teacher_broadcast_options
    else
      []
    end
  end

  # Métodos públicos para obter dados específicos para broadcast
  def schools_for_broadcast
    return School.none unless current_user.user_type == "admin"
    School.all
  end

  def classrooms_for_broadcast
    case current_user.user_type
    when "direction"
      current_user.school.classrooms
    when "teacher"
      # Usar teacher_classrooms que considera os horários
      current_user.teacher_classrooms
    else
      Classroom.none
    end
  end

  private

  def admin_recipients_grouped
    {
      "Direções" => User.directions.where.not(id: current_user.id).includes(:school).to_a,
      "Professores" => User.teachers.includes(:school).to_a,
      "Alunos" => User.students.includes(:classroom, :school).to_a
    }
  end

  def direction_recipients_grouped
    school_users = current_user.school.users.where.not(id: current_user.id).includes(:classroom)

    {
      "Professores" => school_users.teachers.to_a,
      "Alunos" => school_users.students.to_a
    }
  end

  def teacher_recipients_grouped
    # Direção da escola
    direction_users = current_user.school.directions.includes(:school).to_a

    # Alunos das turmas do professor através dos horários
    # Usar teacher_classrooms que já considera os class_schedules
    classroom_ids = current_user.teacher_classrooms.pluck(:id).uniq
    student_users = User.where(classroom_id: classroom_ids, user_type: "student").includes(:classroom, :school).to_a

    # Outros professores da escola
    teacher_users = current_user.school.teachers.where.not(id: current_user.id).includes(:school).to_a

    recipients = {}
    recipients["Direção"] = direction_users unless direction_users.empty?
    recipients["Professores"] = teacher_users unless teacher_users.empty?
    recipients["Alunos"] = student_users unless student_users.empty?

    recipients
  end

  def student_recipients_grouped
    return {} unless current_user.classroom

    # Professores das matérias do aluno (via class_schedules)
    # Buscar disciplinas que têm horários na turma do aluno
    teacher_ids = Subject.joins(:class_schedules)
                         .where(class_schedules: { classroom: current_user.classroom })
                         .where.not(user_id: nil)
                         .pluck(:user_id)
                         .uniq
    
    # Adicionar também professores das disciplinas diretas da turma
    direct_teacher_ids = current_user.classroom.subjects.where.not(user_id: nil).pluck(:user_id)
    teacher_ids = (teacher_ids + direct_teacher_ids).uniq
    
    teacher_users = User.where(id: teacher_ids).includes(:school).to_a

    # Direção da escola
    direction_users = current_user.school.directions.includes(:school).to_a

    recipients = {}
    recipients["Direção"] = direction_users unless direction_users.empty?
    recipients["Professores"] = teacher_users unless teacher_users.empty?

    recipients
  end

  def admin_broadcast_options
    [
      {
        key: "all_directions",
        title: "Todas as Direções",
        description: "Enviar para todos os diretores",
        icon: "fas fa-user-tie",
        color: "primary"
      },
      {
        key: "all_teachers",
        title: "Todos os Professores",
        description: "Enviar para todo o corpo docente",
        icon: "fas fa-chalkboard-teacher",
        color: "success"
      },
      {
        key: "all_students",
        title: "Todos os Alunos",
        description: "Enviar para todos os estudantes",
        icon: "fas fa-user-graduate",
        color: "info"
      },
      {
        key: "by_school",
        title: "Por Escola",
        description: "Enviar para usuários de uma escola específica",
        icon: "fas fa-school",
        color: "warning"
      }
    ]
  end

  def direction_broadcast_options
    [
      {
        key: "all_school",
        title: "Toda a Escola",
        description: "Professores e alunos da escola",
        icon: "fas fa-users",
        color: "primary"
      },
      {
        key: "all_teachers",
        title: "Todos os Professores",
        description: "Apenas corpo docente",
        icon: "fas fa-chalkboard-teacher",
        color: "success"
      },
      {
        key: "all_students",
        title: "Todos os Alunos",
        description: "Apenas estudantes",
        icon: "fas fa-user-graduate",
        color: "info"
      },
      {
        key: "by_classroom",
        title: "Por Turma",
        description: "Alunos de uma turma específica",
        icon: "fas fa-users-class",
        color: "warning"
      }
    ]
  end

  def teacher_broadcast_options
    # Verificar se o professor tem turmas através dos horários
    return [] if current_user.teacher_classrooms.empty?

    [
      {
        key: "my_students",
        title: "Meus Alunos",
        description: "Todos os alunos de suas turmas",
        icon: "fas fa-user-graduate",
        color: "info"
      },
      {
        key: "by_classroom",
        title: "Por Turma",
        description: "Alunos de uma turma específica",
        icon: "fas fa-users-class",
        color: "warning"
      }
    ]
  end
end
