class Monster < ActiveRecord::Base
	has_many :votes, class_name: "Vote", foreign_key: "leader_id", dependent: :destroy
	#has_many :leaders, class_name: "Monster", foreign_key: "id", through: :votes
	#has_many :subs, class_name: "Monster",  foreign_key: "id", through: :votes
	has_many :comments, class_name: "Comment", foreign_key: "id", through: :leaders
	acts_as_taggable
	validates :name, presence: true
	
	def self.top
		where('votes_count > 0').order('votes_count DESC').limit(10)
	end

	#Uses default parameters to fetch data. Fetches all data up from specified month
	def score(intSub)
		score = fetch_weighted_avg(intSub, 0)
		if score.is_a?(Float) and score.nan?
			return 0
		else
			return score
		end
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
		#puts "until:" + m.to_s
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
		#puts "between: " + m.to_s + " and " + m2.to_s
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
	
	def tooltip
		return id.to_s + ". " + name
	end
	def tag_delim
		results = ""
		self.tag_list.each do |t|
			results = results + t + ", "
		end
		return results[0..results.length-3]
	end
	def tag_delim_pair(sub_id)
		results = ""
		self.tag_list_on("sub_" + sub_id.to_s).each do |t|
			results = results + t + ", "
		end
		return results[0..results.length-3]
	end
	
	def detailed_tooltip(id)
		results = (Monster.find(id).tooltip + "&#13;Tags: " + Monster.find(id).tag_delim + "&#13;Pairing Specific Tags: " + tag_delim_pair(id)).html_safe
	end
	
	def get_base_evo
		evos = Rails.cache.fetch("evolutions")
		last = id
		current = id
		dupe = Array.new
		while current != 0 do
			evos.each do |item|
				current = 0
				evos[item[0].to_s].each do |e|
					if e["evolves_to"] == last and not dupe.include?(item[0].to_i)
						current = item[0].to_i
						dupe.push(current)
						break
					end
				end
				if current != 0
					last = current
					break
				end
				
			end
		end
		return last
			
	end
	
	def self.get_next_evo(id)
		results = Array.new
		evos = Rails.cache.fetch("evolutions")[id.to_s]
		if evos != nil
			evos.each do |e|
				results.push(e["evolves_to"])
			end
		end
		results
	end
	
	#def get_prior_evo
	#	evos = Rails.cache.fetch("evolutions")
	#	last = id
	#	current = 0
	#	evos.each do |item|
	#		evos[item[0].to_s].each do |e|
	#			if e["evolves_to"] == last
	#				current = item[0].to_i
	#				break
	#			end
	#		end
	#		if current != 0
	#			last = current
	#			break
	#		end
	#	end
	#	return current == 0 ? id : last
	#end
	
	def get_all_evo
		results = Array.new
		Monster.traverse_evo(get_base_evo, 0, results)
	end
	def self.traverse_evo(id, level, results)
		
		if not results.include?(Monster.find(id))
			#puts Monster.find(id)
			results.push(Monster.find(id))
			Monster.get_next_evo(id).each do |m|
				traverse_evo(m, level + 1, results)
			end
		end
		return results

	end

end
