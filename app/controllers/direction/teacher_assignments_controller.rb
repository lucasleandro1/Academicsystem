class Direction::TeacherAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_direction!

  def index
    @school = current_user.school
    @teachers = @school.teachers.active.includes(:teacher_subjects)
    @classrooms = @school.classrooms.includes(:subjects)
    @unassigned_teachers = @teachers.left_joins(:teacher_subjects).where(subjects: { id: nil })
    @unassigned_subjects = @school.subjects.where(user_id: nil)
  end

  def assign_teacher
    @subject = Subject.find(params[:subject_id])
    @teacher = User.find(params[:teacher_id])

    if @subject.update(user: @teacher)
      redirect_to direction_teacher_assignments_path,
                  notice: "Professor #{@teacher.full_name} atribuído à disciplina #{@subject.name} com sucesso."
    else
      redirect_to direction_teacher_assignments_path,
                  alert: "Erro ao atribuir professor à disciplina."
    end
  end

  def remove_assignment
    @subject = Subject.find(params[:subject_id])

    if @subject.update(user: nil)
      redirect_to direction_teacher_assignments_path,
                  notice: "Professor removido da disciplina #{@subject.name} com sucesso."
    else
      redirect_to direction_teacher_assignments_path,
                  alert: "Erro ao remover professor da disciplina."
    end
  end

  def bulk_assign
    assignments = params[:assignments] || {}
    success_count = 0
    error_count = 0

    assignments.each do |subject_id, teacher_id|
      next if teacher_id.blank?

      subject = Subject.find(subject_id)
      teacher = teacher_id == "unassign" ? nil : User.find(teacher_id)

      if subject.update(user: teacher)
        success_count += 1
      else
        error_count += 1
      end
    end

    if error_count == 0
      redirect_to direction_teacher_assignments_path,
                  notice: "#{success_count} atribuição(ões) realizada(s) com sucesso."
    else
      redirect_to direction_teacher_assignments_path,
                  alert: "#{success_count} atribuições realizadas, #{error_count} falharam."
    end
  end

  private

  def ensure_direction!
    unless current_user&.direction?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
