class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :leader, class_name: "Monster", foreign_key: "leader_id"
	belongs_to :sub, class_name: "Monster", foreign_key: "sub_id"
	has_many :c_ratings, dependent: :destroy
	validates :user_id, :leader_id, :sub_id, :comment, presence: true
	
	def score
		c_ratings.sum(:score)
	end
	
	def self.sorted(leader_id, sub_id)
		where(leader_id: leader_id, sub_id: sub_id).order(:created_at).sort_by(&:score).reverse
	end
	
	def self.latest
		where("comment <> '[deleted]'").order(created_at: :desc).limit(Rails.application.config.fp_display_max_monsters)
	end
	
	def self.model_gen(t)
  		case t
			when "ls"
				return Comment
			when "ll"
				return CommentLl
		end
	end
end
