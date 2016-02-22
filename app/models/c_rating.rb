class CRating < ActiveRecord::Base
	belongs_to :comment, dependent: :destroy
	belongs_to :user, dependent: :destroy
	validates :comment_id, :user_id, :score, presence: true
	validates_uniqueness_of :comment_id, scope: :user_id
	
	
end
