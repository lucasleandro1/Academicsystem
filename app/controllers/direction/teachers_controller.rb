class Direction::TeachersController < ApplicationController
  def index
    @teachers = Teacher.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

def create
  ActiveRecord::Base.transaction do
    @user = User.new(user_params.merge(user_type: :teacher))

    if @user.save
      @user.create_teacher!(
        position: params[:user][:position],
        specialization: params[:user][:specialization]
      )
      redirect_to direction_teachers_path, notice: "Professor criado com sucesso."
    else
      raise ActiveRecord::Rollback
    end
  end
rescue
  render :new
end


  def update
  end

  def destroy
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :school_id, :active)
  end
end
