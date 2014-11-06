class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.float :long
      t.float :lat
      t.string :dest
      t.string :prev_dest
      t.string :last_port
      t.date :eta
      t.datetime :eta_time
      t.string :nav_status
      t.date :last_upt
      t.references :vessel

      t.timestamps
    end
  end
end
