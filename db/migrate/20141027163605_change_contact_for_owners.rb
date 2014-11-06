class ChangeContactForOwners < ActiveRecord::Migration
  change_table :owners do |t|
  	t.change :contact, :text
  end
end
