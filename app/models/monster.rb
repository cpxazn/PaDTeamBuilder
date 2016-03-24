class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	#has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	#has_many :subs, class_name: "Monster",  foreign_key: "id", through: :votes
	has_many :leader_comments, class_name: "Comment", foreign_key: "leader_id", dependent: :destroy
	has_many :sub_comments, class_name: "Comment", foreign_key: "sub_id", dependent: :destroy
	attr_accessor :url, :avg, :avg_count, :user_score
	acts_as_taggable
	validates :name, presence: true
	
	def self.query_gen(t, m1, m2)
		case t
			when "ls"
				return "leader_id = ? and sub_id = ? "
			when "ll"
				if m1 == m2
					return "? = leaders[1] and ? = leaders[2] "
				else
					return "? = ANY(leaders) and ? = ANY(leaders) "
				end		
		end
	end
	def self.model_gen(t)
		case t
			when "ls"
				return Vote
			when "ll"
				return VoteLl
		end
	end
	def self.ll_check(l, s, p)
		 p = p.sort
			
	end
	
	def self.top
		where('votes_count > 0').order('votes_count DESC').limit(Rails.application.config.fp_display_max_monsters)
	end

	#Uses default parameters to fetch data. Fetches all data up from specified month
	def score(m2, t)
		score = fetch_weighted_avg(m2, 0, t)
		if score.is_a?(Float) and score.nan?
			return 0
		else
			return score
		end
		#return fetch_score_ago(m2, Rails.application.config.vote_display_default).round(1)
	end
	def vote_count(m2, t)
		return fetch_vote_count_all(m2, t)
	end
	
	def fetch_weighted_avg(m2,mnth, t)
		weight_avg_list = Rails.application.config.vote_weighted_avg
		result = 0
		count = 0
		missing = 0
		weight_avg_list.each do |w|
			tmp = 0
			if w[1] == 0
				tmp = fetch_score_until(m2, w[0] + mnth, t) * w[2]
			else
				tmp = fetch_score_between(m2, w[0] + mnth,w[1] + mnth, t) * w[2]
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
	def fetch_score_until(m2, intM, t)
		mnth = fetch_vote_date_eom(intM)
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at <= ?", self.id, m2, mnth)			
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_until(m2, intM, t)
		mnth = fetch_vote_date_eom(intM)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at <= ?", self.id, m2, mnth).count
	end
	
	#Fetches all data up from specified month
	def fetch_score_ago(m2, intM, t)
		mnth = fetch_vote_date_eom(intM)
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ?", self.id, m2, mnth)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago(m2, intM, t)
		mnth = fetch_vote_date_eom(intM)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ?", self.id, m2, mnth).count
	end
	
	#Fetches data between two specified month
	def fetch_score_between(m2, intM, intM2, t)
		mnth = fetch_vote_date_eom(intM)
		mnth2 = fetch_vote_date_bom(intM2)
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at <= ? and created_at >= ?", self.id, m2, mnth, mnth2)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_between(m2, intM, intM2, t)
		mnth = fetch_vote_date_eom(intM)
		mnth2 = fetch_vote_date_bom(intM2)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at <= ? and created_at >= ?", self.id, m2, mnth, mnth2).count
	end
	
	#Fetches average for a specific month, from start of month to end of month
	def fetch_score_by_month(m2, mnth, t)
		date = Time.local(mnth.months.ago.year,mnth.months.ago.month,1,0,0,0)
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ? and created_at <= ?", self.id, m2, date, date.end_of_month)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_by_month(m2, mnth, t)
		date = Time.local(mnth.months.ago.year,mnth.months.ago.month,1,0,0,0)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ? and created_at <= ?", self.id, m2, date, date.end_of_month).count
	end
	
	#Fetches data from beginning of specified month up until now
	def fetch_score_ago_beg(m2, mnth, t)
		#date = Time.local(mnth.months.ago.year,mnth.months.ago.month,1,0,0,0)
		mnth = mnth.months.ago.beginning_of_month
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ?", self.id, m2, mnth)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_ago_beg(m2, mnth, t)
		date = Time.local(mnth.months.ago.year,mnth.months.ago.month,1,0,0,0)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2) + "and created_at >= ?", self.id, m2, date).count
	end
	
	#Fetch date depending on Rails config
	def fetch_vote_date_eom(mnth)
		return Rails.application.config.vote_display_eom ? mnth.months.ago.end_of_month : mnth.months.ago
	end
	def fetch_vote_date_bom(mnth)
		return Rails.application.config.vote_display_eom ? mnth.months.ago.beginning_of_month : mnth.months.ago
	end
	
	#Fetches all data
	def fetch_score_all(m2, t)
		vote = Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2), self.id, m2)
		return vote.count > 0 ? (vote.sum(:score).round(1) / vote.count).round(1) : 0
	end
	def fetch_vote_count_all(m2, t)
		return Monster.model_gen(t).where(Monster.query_gen(t, self.id, m2), self.id, m2).count	
	end
	
	
	#Returns sub object
	def subs
		subs_list = Vote.where(leader_id: self.id).select('DISTINCT sub_id').map(&:sub_id)
		result = Array.new
		subs_list.each do |s|
			result.push(id: s, score: score(s,"ls"))
		end
		return result
	end
	#Returns leader object
	def leaders
		leader_list = Vote.where(sub_id: self.id).select('DISTINCT leader_id').map(&:leader_id)
		result = Array.new
		leader_list.each do |l|
			result.push(id: l, score: Monster.find(l).score(self.id,"ls"))
		end
		return result
	end
	
	def ll
		VoteLl.where("'?' = ANY(leaders)",id).select('DISTINCT leaders')
	end
	
	def ll_list
		beforeList = Array.new
		ll.each do |l|
			if l.leaders.size == 2
				if l.leaders[0] == l.leaders[1] then
					beforeList.push(l.leaders[0])
				else
					l.leaders = l.leaders.reject{|a| a == id}[0]
					beforeList.push(l.leaders)
				end
			end
		end
		beforeList = beforeList.uniq
		
		result = Array.new
		beforeList.each do |l|
			result.push(id: l, score: Monster.find(self.id).score(l,"ll"))
		end
		result
	end
	
	def tooltip
		return id.to_s + ". " + name
	end
	def tag_delim
		results = ""
		tmp = Array.new
		self.tag_list.sort.each do |t|
			if not t.include? "attr:"
				
				if t.include? "active skill" or t.include? "leader skill" or t.include? "awoken skill"
						t = t.split(": ")[1]
				end
				tmp.push(t)
			end
		end
		tmp.sort!
		tmp.each do |t|
			if results != "" then results = results + ", " end
			results = results + t
		end
		return results
	end
	def tag_delim_pair(sub_id, t)
		results = ""
		if t != "ll"
			self.tag_list_on(t + "_" + sub_id.to_s).sort.each do |tag|
				if results != "" then results = results + ", " end
				results = results + tag
			end
		else
			if self.id <= sub_id
				id1 = self.id
				id2 = sub_id
			else
				id1 = sub_id
				id2 = self.id
			end
			Monster.find(id1).tag_list_on(t + "_" + id2.to_s).sort.each do |tag|
				if results != "" then results = results + ", " end
				results = results + tag
			end
		end
		return results
	end
end
