class VoteLl < ActiveRecord::Base
	belongs_to :user, counter_cache: true
	validates :user_id, :score, presence: true
	
end
