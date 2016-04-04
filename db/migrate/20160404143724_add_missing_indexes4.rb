    class AddMissingIndexes4 < ActiveRecord::Migration
      def change
        add_index :monster_links, :monster_id
        add_index :monster_links, :user_id
        add_index :monster_links, :version_id
        add_index :ml_ratings, :monster_link_id
        add_index :ml_ratings, :user_id
        add_index :dungeons, :dungeon_group_id
      end
    end