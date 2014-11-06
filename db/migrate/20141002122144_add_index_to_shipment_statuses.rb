class AddIndexToShipmentStatuses < ActiveRecord::Migration
  def change
    add_index :shipment_statuses, :shipment_id
  end
end
