class Direction::TeachersController < ApplicationController
  def index
    @teachers = User.teacher
  end

  def show
    @teacher = User.teacher.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.teacher.find(params[:id])
  end

  def create
    @user = User.new(user_params.merge(user_type: :teacher))

    if @user.save
      redirect_to direction_teachers_path, notice: "Professor criado com sucesso."
    else
      render :new
    end
  end

  def update
    @user = User.teacher.find(params[:id])

    if @user.update(user_params)
      redirect_to direction_teachers_path, notice: "Professor atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @user = User.teacher.find(params[:id])
    @user.destroy
    redirect_to direction_teachers_path, notice: "Professor removido com sucesso."
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :school_id, :active, :position, :specialization
    )
  end
end
