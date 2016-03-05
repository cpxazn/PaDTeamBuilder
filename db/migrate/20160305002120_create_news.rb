class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.text :title
      t.text :news
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
