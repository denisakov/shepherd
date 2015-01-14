class AddStartTimeToShipmentStatuses < ActiveRecord::Migration
  def change
    add_column :shipment_statuses, :start_time, :datetime
  end
end
