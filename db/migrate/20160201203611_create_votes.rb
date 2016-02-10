class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :score
	  t.integer :leader_id
	  t.integer :sub_id
	  t.integer :user_id
      t.timestamps
    end
  end
end
