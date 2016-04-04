class CreateDungeons < ActiveRecord::Migration
  def change
    create_table :dungeons do |t|
      t.integer :dungeon_group_id
      t.string :name
      t.integer :stamina
      t.integer :floors
      t.integer :coins
      t.integer :exp
      t.string :img
	  t.string :dungeon_type
	  t.integer :order


      t.timestamps null: false
    end
  end
end
