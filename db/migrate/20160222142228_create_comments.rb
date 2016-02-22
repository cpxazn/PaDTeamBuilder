class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :leader_id
      t.integer :sub_id
      t.text :comment
      t.integer :parent_id

      t.timestamps
    end
  end
end
