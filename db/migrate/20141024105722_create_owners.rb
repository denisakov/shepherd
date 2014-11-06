class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name
      t.string :rus_name
      t.string :contact
      t.string :notes

      t.timestamps
    end
  end
end
