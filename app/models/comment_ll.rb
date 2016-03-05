class CommentLl < ActiveRecord::Base
	belongs_to :user
	has_many :c_ll_ratings, dependent: :destroy
	validates :user_id, :leaders, :comment, presence: true
	
	def self.sorted(m1, m2)
		where(Monster.query_gen("ll",m1,m2),m1,m2).order(:created_at).sort_by(&:score).reverse
	end
	
	def score
		c_ll_ratings.sum(:score)
	end
	
	def self.latest
		where("comment <> '[deleted]'").order(created_at: :desc).limit(Rails.application.config.fp_display_max_monsters)
	end
	def leader1
		return Monster.find(leaders[0])
	end
	def leader2
		return Monster.find(leaders[1])
	end
end
