class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
	validates :username, :presence => true, :uniqueness => {:case_sensitive => false} 
	validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
	has_many :votes, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :vote_lls, dependent: :destroy
	
	def self.top
		where('votes_count > 0').order('votes_count desc').limit(Rails.application.config.fp_display_max_users)
	end
end
