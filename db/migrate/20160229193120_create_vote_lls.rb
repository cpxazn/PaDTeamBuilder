class CreateVoteLls < ActiveRecord::Migration
  def change
    create_table :vote_lls do |t|
      t.integer :leaders, array: true
      t.integer :user_id
      t.integer :score

      t.timestamps null: false
    end
  end
end
