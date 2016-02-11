class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	
	def score(intSub)
		Vote.where(leader_id: self.id, sub_id: intSub).sum(:score)
	end
	
	def subs
		subs_list = Vote.where(leader_id: self.id).select('DISTINCT sub_id').map(&:sub_id)
		result = Array.new
		subs_list.each do |s|
			result.push(id: s, score: score(s))
		end
		return result
	end
	
	def leaders
		leader_list = Vote.where(sub_id: self.id).select('DISTINCT leader_id').map(&:leader_id)
		result = Array.new
		leader_list.each do |l|
			result.push(id: l, score: Monster.find(l).score(self.id))
		end
		return result
	end
end
