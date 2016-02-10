class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	
	def score(intSub)
		Vote.where(leader_id: self.id, sub_id: intSub).sum(:score)
	end
	
	def subs
		Vote.select('DISTINCT sub_id')
	end
end
