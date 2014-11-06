require 'rake'
Shepherd::Application.load_tasks

class OwnersController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :set_owner, only: [:show, :edit, :update, :destroy]

  def index
    @owners = Owner.preload(:vessels).order('owners.name ASC')
    #respond_with(@owners)
  end

  def show
    # respond_with(@owner)
  end

  def new
    @owner = Owner.new
    #respond_with(@owner)
  end

  def edit
  end

  def create
    @owner = Owner.new(owner_params)
    @owner.save
    #respond_with(@owner)
  end

  def update
    respond_to do |format|
      if @owner.update(owner_params)
        format.html { redirect_to @owner, notice: "Owner's info was successfully updated." }
        format.json { render :show, status: :created, location: @owner }
      else
        format.html { render :edit }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @owner.destroy
    respond_to do |format|
      format.html { redirect_to owners_url, notice: 'Owner was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
    #respond_with(@owner)
  end

  private
    def set_owner
      @owner = Owner.find(params[:id])
    end

    def owner_params
      params.require(:owner).permit(:name, :rus_name, :contact, :notes)
    end
end
