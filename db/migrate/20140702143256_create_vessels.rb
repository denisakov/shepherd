class CreateVessels < ActiveRecord::Migration
  def change
    create_table :vessels do |t|
      t.string :vsl_name
      t.string :vsl_type
      t.date :blt_year
      t.string :vsl_flag

      t.timestamps
    end
  end
end
