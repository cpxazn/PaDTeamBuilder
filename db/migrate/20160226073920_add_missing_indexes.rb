    class AddMissingIndexes < ActiveRecord::Migration
      def change
        add_index :c_ratings, :comment_id
        add_index :c_ratings, :user_id
        #add_index :comments, :monster_id
        add_index :comments, :user_id
        add_index :comments, :leader_id
        add_index :comments, :sub_id
        #add_index :taggings, [:acts_as_taggable_on/tag_id, :monster_id]
        add_index :votes, :leader_id
        add_index :votes, :sub_id
        add_index :votes, :user_id
      end
    end