class CreateCLlRatings < ActiveRecord::Migration
  def change
    create_table :c_ll_ratings do |t|
      t.integer :user_id
      t.string :comment_ll_id
      t.integer :score

      t.timestamps null: false
    end
  end
end
