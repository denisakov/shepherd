class AddIndexToPositions < ActiveRecord::Migration
  def change
    add_index :positions, :vessel_id
  end
end
