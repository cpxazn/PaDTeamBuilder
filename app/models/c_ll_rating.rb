class CLlRating < ActiveRecord::Base
	belongs_to :comment_ll, dependent: :destroy
	belongs_to :user, dependent: :destroy
	validates :comment_ll_id, :user_id, :score, presence: true
	validates_uniqueness_of :comment_ll_id, scope: :user_id
end
