class AddVoteLlsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vote_lls_count, :integer
  end
end
