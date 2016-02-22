class Comment < ActiveRecord::Base
	belongs_to :monster, dependent: :destroy
	belongs_to :user, dependent: :destroy
	has_many :c_ratings
	validates :user_id, :leader_id, :sub_id, :comment, presence: true
	
	def score
		c_ratings.sum(:score)
	end
	
	def self.sorted(leader_id, sub_id)
		where(leader_id: leader_id, sub_id: sub_id).order(:created_at).sort_by(&:score).reverse
	end
end
