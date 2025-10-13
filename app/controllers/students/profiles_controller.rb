class Students::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def show
    @user = current_user
    @classroom = @user.classroom
    @school = current_user.school

    # Calcular estatísticas para o resumo acadêmico
    if @classroom
      @total_subjects = @classroom.class_schedules.joins(:subject).distinct.count("subjects.id")

      # Buscar disciplinas da turma do usuário
      subjects_in_classroom = @classroom.class_schedules.joins(:subject).pluck("subjects.id").uniq

      # Calcular média geral das notas
      grades = Grade.joins(:subject)
                   .where(subject_id: subjects_in_classroom)
                   .where(user_id: current_user.id)

      @overall_average = grades.any? ? grades.average(:value)&.round(1) : nil

      # Calcular frequência
      total_classes = @classroom.class_schedules.count * 30 # Assumindo 30 aulas por disciplina
      absences_count = Absence.joins(:subject)
                             .where(subject_id: subjects_in_classroom)
                             .where(user_id: current_user.id)
                             .count

      @attendance_rate = total_classes > 0 ? ((total_classes - absences_count) * 100.0 / total_classes).round(1) : 100.0

      # Notas recentes
      @recent_grades = grades.includes(:subject)
                            .order(created_at: :desc)
                            .limit(3)
    else
      @total_subjects = 0
      @overall_average = nil
      @attendance_rate = 0
      @recent_grades = []
    end
  end

  def edit
    @student = current_user
  end

  def update
    @student = current_user
    if @student.update(student_params)
      redirect_to students_profile_path, notice: "Perfil atualizado com sucesso."
    else
      render :edit
    end
  end

  private

  def ensure_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def student_params
    params.require(:user).permit(:first_name, :last_name, :phone, :birth_date, :guardian_name)
  end
end
