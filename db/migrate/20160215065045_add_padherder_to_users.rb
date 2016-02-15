class AddPadherderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :padherder, :string
  end
end
