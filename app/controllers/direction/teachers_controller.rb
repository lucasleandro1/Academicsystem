class TeachersController < ApplicationController
  def index
    @directions = Direction.all
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def set_direction
    @direction = Direction.find(params.expect(:id))
  end

  def direction_params
    params.expect(direction: [ :user_id ])
  end
end
