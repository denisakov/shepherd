class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :title
      t.references :vessel
      t.timestamps
    end
  end
end
