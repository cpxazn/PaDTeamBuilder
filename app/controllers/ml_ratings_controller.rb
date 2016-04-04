class MlRatingsController < ApplicationController
	before_action :authenticate_user!, only: [:create]
	
	def create
		monster_link_id = params[:monster_link_id]
		if monster_link_id == nil
			redirect_to root_path, alert: "Error: No Links Provided " 
			return
		end
		
		monster_link = MonsterLink.find(monster_link_id)
		if monster_link == nil
			redirect_to monster_link.monster, alert: "Error: Link ID not found" 
			return
		end

		if current_user == monster_link.user
			redirect_to monster_link.monster, alert: "Error: Cannot like your own link"
			return
		end
		
		if current_user.ml_ratings.where(monster_link_id: monster_link_id).count >=1
			redirect_to monster_link.monster, alert: "Error: Link has already been liked"
			return
		end

		ml_rating = MlRating.new(monster_link_id: monster_link_id, user_id: current_user.id, score: 1)
		
		if ml_rating.save
			redirect_to monster_link.monster, anchor: "ml_" +  monster_link_id,notice: "Link has been liked"
		else
			redirect_to monster_link.monster, alert: "Error: Unable to save 'like'" 
		end
	end
	
end
