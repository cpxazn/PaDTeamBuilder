class AddVotesCountToMonsters < ActiveRecord::Migration
  def change
    add_column :monsters, :votes_count, :integer
  end
end
