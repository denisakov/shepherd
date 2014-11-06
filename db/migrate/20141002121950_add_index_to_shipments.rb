class AddIndexToShipments < ActiveRecord::Migration
  def change
    add_index :shipments, :vessel_id
  end
end
