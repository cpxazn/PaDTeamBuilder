class Vote < ActiveRecord::Base
	belongs_to :leader, class_name: "Monster", foreign_key: "leader_id"
	belongs_to :sub, class_name: "Monster", foreign_key: "sub_id"
	belongs_to :user
	validates :leader_id, :sub_id, :user_id, :score, presence: true
	#validates_uniqueness_of :sub_id, scope: [:user_id, :leader_id]
	

end
