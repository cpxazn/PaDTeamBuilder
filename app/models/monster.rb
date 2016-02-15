class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	
	#Uses default parameters to fetch data. Fetches all data up from specified month
	def score(intSub)
		return fetch_weighted_avg(intSub, 0)
		#return fetch_score_ago(intSub, Rails.application.config.vote_display_default).round(1)
	end
	def vote_count(intSub)
		return fetch_vote_count_all(intSub)
	end
	
	def fetch_weighted_avg(intSub,m)
		weight_avg_list = Rails.application.config.vote_weighted_avg
		result = 0
		count = 0
		missing = 0
		weight_avg_list.each do |w|
			tmp = 0
			if w[1] == 0
				tmp = fetch_score_until(intSub, w[0] + m) * w[2]
			else
				tmp = fetch_score_between(intSub, w[0] + m,w[1] + m) * w[2]
			end
			if tmp > 0
				count = count + 1
				result = result + tmp
			else
				missing = missing + w[2]
			end
		end
		if missing > 0 then result = result / (1 - missing) end
		return (result).round(1)
	end
	
	#Fetches all data up until specified month
	def fetch_score_until(intSub, intM)
		m = fetch_vote_date_eom(intM)
		puts "until:" + m.to_s
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at <= ?", self.id, intSub, m)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_until(intSub, intM)
		m = fetch_vote_date_eom(intM)
		return Vote.where("leader_id = ? and sub_id = ? and created_at <= ?", self.id, intSub, m).count
	end
	
	#Fetches all data up from specified month
	def fetch_score_ago(intSub, intM)
		m = fetch_vote_date_eom(intM)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at >= ?", self.id, intSub, m)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago(intSub, intM)
		m = fetch_vote_date_eom(intM)
		return Vote.where("leader_id = ? and sub_id = ? and created_at >= ?", self.id, intSub, m).count
	end
	
	#Fetches data between two specified month
	def fetch_score_between(intSub, intM, intM2)
		m = fetch_vote_date_eom(intM)
		m2 = fetch_vote_date_bom(intM2)
		puts "between: " + m.to_s + " and " + m2.to_s
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at <= ? and created_at >= ?", self.id, intSub, m, m2)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_between(intSub, intM, intM2)
		m = fetch_vote_date_eom(intM)
		m2 = fetch_vote_date_bom(intM2)
		return Vote.where("leader_id = ? and sub_id = ? and created_at <= ? and created_at >= ?", self.id, intSub, m, m2).count
	end
	
	#Fetches average for a specific month, from start of month to end of month
	def fetch_score_by_month(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at >= ? and created_at <= ?", self.id, intSub, date, date.end_of_month)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_by_month(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		return Vote.where("leader_id = ? and sub_id = ? and created_at >= ? and created_at <= ?", self.id, intSub, date, date.end_of_month).count
	end
	
	#Fetches data from beginning of specified month up until now
	def fetch_score_ago_beg(intSub, m)
		#date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		m = m.months.ago.beginning_of_month
		vote = Vote.where("leader_id = ? and sub_id = ? and created_at >= ?", self.id, intSub, m)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago_beg(intSub, m)
		date = Time.local(m.months.ago.year,m.months.ago.month,1,0,0,0)
		return Vote.where("leader_id = ? and sub_id = ? and created_at >= ?", self.id, intSub, date).count
	end
	
	#Fetch date depending on Rails config
	def fetch_vote_date_eom(m)
		return Rails.application.config.vote_display_eom ? m.months.ago.end_of_month : m.months.ago
	end
	def fetch_vote_date_bom(m)
		return Rails.application.config.vote_display_eom ? m.months.ago.beginning_of_month : m.months.ago
	end
	
	#Fetches all data
	def fetch_score_all(intSub)
		vote = Vote.where(leader_id: self.id, sub_id: intSub)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_all(intSub)
		return Vote.where(leader_id: self.id, sub_id: intSub).count	
	end
	
	
	#Returns sub object
	def subs
		subs_list = Vote.where(leader_id: self.id).select('DISTINCT sub_id').map(&:sub_id)
		result = Array.new
		subs_list.each do |s|
			result.push(id: s, score: score(s))
		end
		return result
	end
	#Returns leader object
	def leaders
		leader_list = Vote.where(sub_id: self.id).select('DISTINCT leader_id').map(&:leader_id)
		result = Array.new
		leader_list.each do |l|
			result.push(id: l, score: Monster.find(l).score(self.id))
		end
		return result
	end
end
