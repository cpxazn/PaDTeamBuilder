class VoteLl < ActiveRecord::Base
	belongs_to :user, counter_cache: true
	validates :user_id, :score, presence: true
	
	def leader1
		return Monster.find(leaders[0])
	end
	def leader2
		return Monster.find(leaders[1])
	end
end
