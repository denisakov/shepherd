class AddOwnerRefToVessels < ActiveRecord::Migration
  def change
    add_reference :vessels, :owner, index: true
  end
end
