class VesselsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_vessel, only: [:show, :edit, :update, :destroy]

  def index
    @vessels = Vessel.all
  end

  def show
  end

  def new
    @vessel = Vessel.new
  end

  def edit
  end

  def create
    @vessel = Vessel.new(vessel_params)

    respond_to do |format|
      if @vessel.save
        format.html { redirect_to @vessel, notice: 'Vessel card was successfully created.' }
        format.json { render :show, status: :created, location: @vessel }
      else
        format.html { render :new }
        format.json { render json: @vessel.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @vessel.update(vessel_params)
        format.html { redirect_to @vessel, notice: "Vessel's info was successfully updated." }
        format.json { render :show, status: :ok, location: @vessel }
      else
        format.html { render :edit }
        format.json { render json: @vessel.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vessel.destroy
    respond_to do |format|
      format.html { redirect_to vessels_url, notice: 'Vessel was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vessel
      @vessel = Vessel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vessel_params
      params.require(:vessel).permit(:vsl_name, :vsl_type, :blt_year, :vsl_flag)
    end
end
