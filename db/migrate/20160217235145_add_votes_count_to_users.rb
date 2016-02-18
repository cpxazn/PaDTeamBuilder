class AddVotesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :votes_count, :integer
  end
end
