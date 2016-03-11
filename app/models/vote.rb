class Vote < ActiveRecord::Base
	belongs_to :leader, class_name: "Monster", foreign_key: "leader_id", counter_cache: true
	belongs_to :sub, class_name: "Monster", foreign_key: "sub_id"
	belongs_to :user, counter_cache: true
	validates :leader_id, :sub_id, :user_id, :score, presence: true
	#validates_uniqueness_of :sub_id, scope: [:user_id, :leader_id]
	
	def self.recent_top(m)
		date_condition = m.months.ago
		results = where("created_at > ?", date_condition).group(:leader_id).count
		results = results.sort_by { |leader, count| count }.reverse[0..Rails.application.config.fp_display_max_monsters-1]
	end
	
	def self.outliers(mnth, t)
		case t
			when "ls"
				hMax = Vote.where("created_at > ?", mnth.months.ago).group(:leader_id, :sub_id).maximum(:score)
				hMin = Vote.where("created_at > ?", mnth.months.ago).group(:leader_id, :sub_id).minimum(:score)
			when "ll"
				hMax = VoteLl.where("created_at > ?", mnth.months.ago).group(:leaders).maximum(:score)
				hMin = VoteLl.where("created_at > ?", mnth.months.ago).group(:leaders).minimum(:score)
		end
		result = Array.new
		hMax.each do |mx|
			max = mx[1]
			min = hMin[mx[0]]
			tmp = nil
			if (max - min) >= 6
				avg = Monster.find(mx[0][0]).score(mx[0][1], t)
				count = Monster.find(mx[0][0]).vote_count(mx[0][1], t)
				if (avg - min) > (max - avg)
					#m = Vote.where(leader: mx[0][0], sub: mx[0][1], score: min)
					m = Monster.model_gen(t).where(Monster.query_gen(t, mx[0][0], mx[0][1]) + "and score = ?", mx[0][0], mx[0][1], min)
				elsif (avg - min) <= (max - avg)
					#m = Vote.where(leader: mx[0][0], sub: mx[0][1], score: max)
					m = Monster.model_gen(t).where(Monster.query_gen(t, mx[0][0], mx[0][1]) + "and score = ?", mx[0][0], mx[0][1], max)
				end
				m.each do |v|
					tmp = {vote: v, average: avg, count: count, timestamp: v.created_at}	
					result.push(tmp)
				end
			end
		end
		result.sort_by! { |item| item[:timestamp] }.reverse[0..Rails.application.config.questionable_display_max-1]
	end
	
	def self.low_count(mnth, t)
		case t
			when "ls"
				h = Vote.where("created_at > ?", mnth.months.ago).group(:leader_id, :sub_id).count
			when "ll"
				h = VoteLl.where("created_at > ?", mnth.months.ago).group(:leaders).count
		end
		h = h.map {
			|item| if item[1] <= 3 then
				item
			end
		}.compact.shuffle.first(Rails.application.config.questionable_display_max).sort_by {
				|item| item[1]
		}.map {
			|item| 	item.push(Monster.find(item[0][0]).score(item[0][1],t))
		}

	end
	
	def self.low_rating(mnth, t)
		case t
			when "ls"
				h = Monster.model_gen(t).where("created_at > ?", mnth.months.ago).group(:leader_id, :sub_id).average(:score)
			when "ll"
				h = Monster.model_gen(t).where("created_at > ?", mnth.months.ago).group(:leaders).average(:score)
		end
		h = h.map {
			|item| if item[1] <= Rails.application.config.vote_low_score then
				[item[0], item[1].to_f.round(1)]
			end
		}.compact.shuffle.first(Rails.application.config.questionable_display_max).map{
			|item| {leader: Monster.find(item[0][0]), sub: Monster.find(item[0][1]), average: item[1], count: Monster.find(item[0][0]).vote_count(Monster.find(item[0][1]),t)}
		}.sort_by {
				|item| item[:average]
		}
	end
	
	def self.find_monster_in(m, mnth, t)
		case t
			when "ls"
				h = Monster.model_gen(t).where("(leader_id in (?) or sub_id in (?)) and created_at > ?", m,m, mnth.months.ago).group(:leader_id,:sub_id).average(:score)
			when "ll"
				h = Monster.model_gen(t).where("(leaders[1] in (?) or leaders[2] in (?)) and created_at > ?", m,m, mnth.months.ago).group(:leaders).average(:score)
		end

		h = Hash[h.to_a.shuffle].first(Rails.application.config.questionable_display_max).map{
			|item| {leader: Monster.find(item[0][0]), sub: Monster.find(item[0][1]), average: item[1].to_f.round(1), count: Monster.find(item[0][0]).vote_count(Monster.find(item[0][1]),t)}
		}.sort_by {
				|item| item[:average]
		}
	end
end
