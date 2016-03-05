class CreateCommentLls < ActiveRecord::Migration
  def change
    create_table :comment_lls do |t|
      t.integer :user_id
      t.integer :leaders, array: true
      t.text :comment
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
