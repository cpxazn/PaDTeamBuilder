class DungeonGroup < ActiveRecord::Base
	has_many :dungeons, dependent: :destroy
end
