class DirectionsController < ApplicationController
  before_action :set_direction, only: %i[ show edit update destroy ]

  # GET /directions or /directions.json
  def index
    @directions = Direction.all
  end

  # GET /directions/1 or /directions/1.json
  def show
  end

  # GET /directions/new
  def new
    @direction = Direction.new
  end

  # GET /directions/1/edit
  def edit
  end

  # POST /directions or /directions.json
  def create
    @direction = Direction.new(direction_params)

    respond_to do |format|
      if @direction.save
        format.html { redirect_to @direction, notice: "Direction was successfully created." }
        format.json { render :show, status: :created, location: @direction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @direction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /directions/1 or /directions/1.json
  def update
    respond_to do |format|
      if @direction.update(direction_params)
        format.html { redirect_to @direction, notice: "Direction was successfully updated." }
        format.json { render :show, status: :ok, location: @direction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @direction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /directions/1 or /directions/1.json
  def destroy
    @direction.destroy!

    respond_to do |format|
      format.html { redirect_to directions_path, status: :see_other, notice: "Direction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_direction
      @direction = Direction.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def direction_params
      params.expect(direction: [ :user_id ])
    end
end
