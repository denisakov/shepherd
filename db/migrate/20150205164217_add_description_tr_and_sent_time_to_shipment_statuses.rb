class AddDescriptionTrAndSentTimeToShipmentStatuses < ActiveRecord::Migration
  def change
    add_column :shipment_statuses, :description_tr, :text
    add_column :shipment_statuses, :sent_time, :datetime
  end
end
