class MonsterLink < ActiveRecord::Base
	belongs_to :monster
	belongs_to :user
	belongs_to :version
	has_many :ml_ratings, dependent: :destroy
	validates :user_id, :url, :title, :title, :link_type, presence: true
end
