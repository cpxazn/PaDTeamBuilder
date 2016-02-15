class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	
	#Uses default parameters to fetch data. Fetches all data up from specified month
	def score(intSub)
		return fetch_score_ago(intSub, Rails.application.config.vote_display_default).round(1)
	end
	def vote_count(intSub)
		return fetch_vote_count_ago(intSub, Rails.application.config.vote_display_default)
	end
	
	#Fetches all data up from specified month
	def fetch_score_ago(intSub, m)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, m.months.ago)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago(intSub, m)
		return Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, m.months.ago).count
	end
	
	#Fetches data between two specified month
	def fetch_score_between_ago(intSub, m, m2)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at < ? and created_at > ?", self.id, intSub, m.months.ago, m2.months.ago)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_between_ago(intSub, m, m2)
		return Vote.where("leader_id = ? and sub_id = ? and created_at < ? and created_at > ?", self.id, intSub, m.months.ago, m2.months.ago).count
	end
	
	#Fetches data for a specific month, from start of month to end
	def fetch_score_by_month(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at > ? and created_at < ?", self.id, intSub, date, date.end_of_month)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_by_month(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		return Vote.where("leader_id = ? and sub_id = ? and created_at > ? and created_at < ?", self.id, intSub, date, date.end_of_month).count
	end
	
	#Fetches data from beginning of specified month up until now
	def fetch_score_ago_beg(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, date)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago_beg(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		return Vote.where("leader_id = ? and sub_id = ? and created_at > ?", self.id, intSub, date).count
	end
	
	def fetch_score_all(intSub)
		vote = Vote.where(leader_id: self.id, sub_id: intSub)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
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
