class Vote < ActiveRecord::Base
	belongs_to :leader, class_name: "Monster", foreign_key: "leader_id", counter_cache: true
	belongs_to :sub, class_name: "Monster", foreign_key: "sub_id"
	belongs_to :user, counter_cache: true
	validates :leader_id, :sub_id, :user_id, :score, presence: true
	#validates_uniqueness_of :sub_id, scope: [:user_id, :leader_id]
	
	def self.recent_top(m)
		date_condition = m.months.ago
		results = where("created_at > ?", date_condition).group(:leader_id).count
		results = results.sort_by { |leader, count| count }.reverse[0..9]
	end
	

end
