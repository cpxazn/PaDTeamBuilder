class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	
	def score(intSub)
		return fetch_score(intSub, Rails.application.config.vote_display_default)
	end
	def vote_count(intSub)
		return vote_count(intSub, Rails.application.config.vote_display_default)
	end
	
	def fetch_score(intSub, m)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, m.months.ago)
		return vote.count > 0 ? (vote.sum(:score) / vote.count) : 0
	end
	def fetch_vote_count(intSub, m)
		return Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, m.months.ago).count
	end
	
	def fetch_score_between(intSub, m, m2)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at < ? and created_at > ?", self.id, intSub, m.months.ago, m2.months.ago)
		return vote.count > 0 ? (vote.sum(:score) / vote.count) : 0
	end
	def fetch_vote_count_between(intSub, m, m2)
		return Vote.where("leader_id = ? and sub_id = ? and created_at < ? and created_at > ?", self.id, intSub, m.months.ago, m2.months.ago).count
	end
	
	def fetch_score_all(intSub)
		vote = Vote.where(leader_id: self.id, sub_id: intSub)
		return vote.count > 0 ? (vote.sum(:score) / vote.count) : 0
	end
	def fetch_vote_count_all(intSub)
		return Vote.where(leader_id: self.id, sub_id: intSub).count	
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
