class CreateMlRatings < ActiveRecord::Migration
  def change
    create_table :ml_ratings do |t|
      t.integer :monster_link_id
      t.integer :user_id
      t.integer :score

      t.timestamps null: false
    end
  end
end
