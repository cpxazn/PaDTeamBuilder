class AddPinnedToNews < ActiveRecord::Migration
  def change
    add_column :news, :pinned, :boolean,  :null => false, :default => false
  end
end
