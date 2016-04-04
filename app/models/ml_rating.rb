class MlRating < ActiveRecord::Base
	belongs_to :monster_link
	belongs_to :user
	validates :monster_link_id, :user_id, :score, presence: true
	validates_uniqueness_of :monster_link_id, scope: :user_id
end