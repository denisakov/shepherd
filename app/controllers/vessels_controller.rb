require 'rake'
Shepherd::Application.load_tasks

class VesselsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show, :dash, :non_russian]
  before_action :set_vessel, only: [:show, :edit, :update, :destroy]


  def index
    #@all_vessels = Vessel.preload(:positions).order('vessels.vsl_name ASC').references(:positions)
    #@russian_vessels = Vessel.russian_vessels.preload(:positions).order('vessels.vsl_name ASC')
    @free_vessels = Vessel.free_vessels.preload(:positions).order('vessels.vsl_type ASC')

    respond_to do |format|
      format.pdf do
            render :pdf => "Example PDF file",
                   :template => 'vessels/all.pdf.erb',
                   :print_media_type => true,
                   :page_size => "A4"
      end
      format.html #{ render :index }
    end

  end

  def non_russian
    #@all_vessels = Vessel.preload(:positions).order('vessels.vsl_name ASC').references(:positions)
    #@russian_vessels = Vessel.russian_vessels.preload(:positions).order('vessels.vsl_name ASC')
    @non_russian_vessels = Vessel.free_vessels.where('vsl_flag != ?', "Russia").preload(:positions).order('vessels.vsl_type ASC')

    respond_to do |format|
      format.pdf do
            render :pdf => "Example PDF file",
                   :template => 'vessels/non_russian.pdf.erb',
                   :print_media_type => true,
                   :page_size => "A4"
      end
      format.html { render :non_russian }
    end

  end

  def dash
    #@all_vessels = Vessel.preload(:positions).order('vessels.vsl_name ASC').references(:positions)
    #@russian_vessels = Vessel.russian_vessels.preload(:positions).order('vessels.vsl_name ASC')
    @engaged_vessels = Vessel.engaged_vessels.preload(:positions).order('vessels.vsl_name ASC')
    @active_vessels = Vessel.active_vessels.order('vessels.vsl_name ASC')

    respond_to do |format|
      format.pdf do
            render :pdf => "Example PDF file",
                   :template => 'vessels/active.pdf.erb',
                   :print_media_type => true,
                   :page_size => "A4"
      end
      format.html { render :dash }
    end

  end

  def show
    respond_to do |format|
      format.pdf do
            render :pdf => "Example PDF file",
                   :template => 'vessels/single.pdf.erb',
                   :print_media_type => true,
                   :page_size => "A4"
      end
      format.html { render :show }
    end
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
        format.js { redirect_to @vessel, notice: 'Vessel card was successfully created.' }
      else
        format.html #{ render :new }
        format.json { render json: @vessel.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @vessel.update(vessel_params)
        format.html { redirect_to @vessel, notice: "Vessel's info was successfully updated." }
        format.json { render :show, status: :created, location: @vessel }
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
      format.js
      format.json { head :no_content }
    end
  end

  # def scan
  #     Rake::Task['crawl:new'].invoke
  #     Rake::Task['crawl:new'].reenable
      
  #     respond_to do |format|
  #       format.html { redirect_to vessels_url, success: 'Vessels have been scanned!' }
  #       format.json { head :no_content }
  #     end
  # end

  def scan
      Rake::Task['crawl:new'].reenable
      Rake::Task['crawl:new'].invoke(params[:vessel_imos])

      respond_to do |format|
        format.html { redirect_to dash_path, success: 'Vessel information has been updated!' }
        format.json { head :no_content }
        format.js
      end
  end

  def scan_gps
      Rake::Task['crawl:gps'].reenable
      Rake::Task['crawl:gps'].invoke(params[:vessel_imos])

      respond_to do |format|
        format.html { redirect_to :dash, success: 'Vessel GPS has been updated!' }
        format.json { head :no_content} #{vessel_path(params[:id])}}
        format.js
      end
  end

  def engage
    vessels = Vessel.where(:id => params[:vessel_ids])
    vessels.each do |v|
      s = v.shipments.build(:title => "Change this name")
      v.save!
      s.shipment_statuses.build(:title => "Change this name", :status => "Initialized", :shipment_id => s.id)
      s.save!
    end
    redirect_to :dash
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vessel
      @vessel = Vessel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vessel_params
      params.require(:vessel).permit(:vsl_name, :vsl_type, :blt_year, :vsl_flag, :imo, :mmsi)
    end
end
