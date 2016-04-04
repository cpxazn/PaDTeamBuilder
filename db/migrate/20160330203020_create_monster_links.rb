class CreateMonsterLinks < ActiveRecord::Migration
  def change
    create_table :monster_links do |t|
      t.string :url
      t.integer :user_id
      t.integer :monster_id
	  t.string :link_type
	  t.string :title
	  t.string :version_id
      t.timestamps null: false
    end
  end
end
