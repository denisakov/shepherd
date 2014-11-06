class CreateShipmentStatuses < ActiveRecord::Migration
  def change
    create_table :shipment_statuses do |t|
      t.string :title
      t.references :shipment
      t.string :status
      t.string :next_status
      t.date :next_comp_date
      t.datetime :next_comp_time
      t.datetime :comp_date
      t.datetime :comp_time
      t.timestamps
    end
  end
end
