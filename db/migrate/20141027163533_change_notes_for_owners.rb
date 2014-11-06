class ChangeNotesForOwners < ActiveRecord::Migration
  change_table :owners do |t|
  	t.change :notes, :text
  end
end
