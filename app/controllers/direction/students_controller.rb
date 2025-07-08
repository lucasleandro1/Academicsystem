class Direction::StudentsController < ApplicationController
  def index
    @students = User.student
  end

  def show
    @student = User.student.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.student.find(params[:id])
  end

  def create
    @user = User.new(user_params.merge(user_type: :student))

    if @user.save
      redirect_to direction_students_path, notice: "Professor criado com sucesso."
    else
      render :new
    end
  end

  def update
    @user = User.student.find(params[:id])

    if @user.update(user_params)
      redirect_to direction_students_path, notice: "Professor atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @user = User.student.find(params[:id])
    @user.destroy
    redirect_to direction_students_path, notice: "Aluno removido com sucesso."
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :school_id, :active, :birth_date, :guardian_name
    )
  end
end
