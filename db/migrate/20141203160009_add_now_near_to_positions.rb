class AddNowNearToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :now_near, :text
  end
end
