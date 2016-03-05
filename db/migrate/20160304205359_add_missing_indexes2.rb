    class AddMissingIndexes2 < ActiveRecord::Migration
      def change
        add_index :vote_lls, :user_id
        add_index :votes, :leader_id
        add_index :votes, :sub_id
        add_index :votes, :user_id
        add_index :comment_lls, :user_id
        add_index :comments, :user_id
        add_index :comments, :leader_id
        add_index :comments, :sub_id
        add_index :c_ll_ratings, :comment_ll_id
        add_index :c_ll_ratings, :user_id
      end
    end