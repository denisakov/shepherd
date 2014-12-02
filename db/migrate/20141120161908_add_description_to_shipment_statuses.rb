class AddDescriptionToShipmentStatuses < ActiveRecord::Migration
  def change
    add_column :shipment_statuses, :description, :text
  end
end
