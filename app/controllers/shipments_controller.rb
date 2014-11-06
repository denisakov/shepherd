class ShipmentsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_shipment, only: [:show, :edit, :update, :destroy]

  # GET /shipments
  # GET /shipments.json
  def index
    @active_shipments = Shipment.includes(:shipment_statuses).active
    @completed_shipments = Shipment.includes(:shipment_statuses).done
  end

  # GET /shipments/1
  # GET /shipments/1.json
  def show
  end

  def new
    @shipment = Shipment.new
  end

  def edit
  end

 
  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.save!
    @shipment.shipment_statuses.build(:title => "Change this name", :status => "Initialized", :shipment_id => @shipment.id)
    @shipment.save!
    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: 'Shipment was successfully created.' }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_shipment_status
    @shipment = Shipment.find(params[:id]) 
    @shipment_status = @shipment.shipment_statuses.build(:shipment_id => params[:id], :status => params[:shipment_status][:status])
    @shipment_status.save!
    if @shipment_status.save
      @shipment_status = ShipmentStatus.new
    end
    render :action => :show
  end

  # PATCH/PUT /shipments/1
  # PATCH/PUT /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to @shipment, notice: 'Shipment was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment }
      else
        format.html { render :edit }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipments/1
  # DELETE /shipments/1.json
  def destroy
    @shipment.destroy
    respond_to do |format|
      format.html { redirect_to shipments_url, notice: 'Shipment was successfully deleted.' }
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_params
      params.require(:shipment).permit(:title, :vessel_id)
    end
end
