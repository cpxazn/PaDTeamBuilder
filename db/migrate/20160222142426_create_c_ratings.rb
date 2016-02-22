class CreateCRatings < ActiveRecord::Migration
  def change
    create_table :c_ratings do |t|
      t.integer :user_id
      t.integer :comment_id
      t.integer :score

      t.timestamps
    end
  end
end
