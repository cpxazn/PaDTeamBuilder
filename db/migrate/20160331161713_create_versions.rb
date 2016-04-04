class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :number
      t.text :notes
	  t.date :na_date
	  t.date :jp_date
      t.integer :last_modified_by
      t.timestamps null: false
    end
  end
end
