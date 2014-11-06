class AddGivenNameToOwners < ActiveRecord::Migration
  def change
    add_column :owners, :given_name, :string
  end
end