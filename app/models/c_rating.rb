class CRating < ActiveRecord::Base
	belongs_to :comment, dependent: :destroy
	belongs_to :user, dependent: :destroy
	validates :comment_id, :user_id, :score, presence: true
	validates_uniqueness_of :comment_id, scope: :user_id
	
	def self.model_gen(t)
  		case t
			when "ls"
				return CRating
			when "ll"
				return CLlRating
		end
	end
end
