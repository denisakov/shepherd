class CreateVessels < ActiveRecord::Migration
  def change
    create_table :vessels do |t|
      t.string :vsl_name
      t.string :vsl_type
      t.date :blt_year
      t.string :vsl_flag
      t.string :imo
      t.string :mmsi
      t.string :vsl_proj
      t.string :vsl_dwt
      t.integer :vsl_dwcc
      t.integer :vsl_gt
      t.integer :vsl_nt
      t.integer :vsl_l
      t.integer :vsl_w
      t.integer :vsl_depth
      t.integer :vsl_draft
      t.integer :vsl_cbm
      t.integer :h1_l
      t.integer :h1_w
      t.integer :h1_h
      t.integer :h2_l
      t.integer :h2_w
      t.integer :h2_h
      t.integer :h3_l
      t.integer :h3_w
      t.integer :h3_h
      t.integer :h4_l
      t.integer :h4_w
      t.integer :h4_h
      t.integer :h5_l
      t.integer :h5_w
      t.integer :h5_h
      t.integer :h6_l
      t.integer :h6_w
      t.integer :h6_h
      t.integer :ha1_l
      t.integer :ha1_w
      t.integer :ha1_h
      t.integer :ha2_l
      t.integer :ha2_w
      t.integer :ha2_h
      t.integer :ha3_l
      t.integer :ha3_w
      t.integer :ha3_h
      t.integer :ha4_l
      t.integer :ha4_w
      t.integer :ha4_h
      t.integer :h_safeload
      t.integer :ha_safeload
      t.string :vsl_note
      t.string :vsl_link
      t.string :vsl_cargotype

      t.timestamps
    end
  end
end
