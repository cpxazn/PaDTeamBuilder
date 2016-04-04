class CreateDungeonGroups < ActiveRecord::Migration
  def change
    create_table :dungeon_groups do |t|
      t.string :name
	  t.string :dungeon_type
	  t.integer :order

      t.timestamps null: false
    end
  end
end
