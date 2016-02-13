class ApplicationController < ActionController::Base
	helper_method :user_voted_default_month, :fetch_user_vote_by_default_month

  protect_from_forgery with: :exception
  def fetch_monster_by_id(id)
		if Monster.where(id: id).count > 0
			return Monster.find(id)
		else
			return nil
		end			
  end
  
  def fetch_monster_by_name(name)
		if Monster.where(name: name).count > 0
			return Monster.where(name: name).first
		else
			return nil
		end
  end
  
  def fetch_monster_by_one(id,name)
    id = id.to_i
	if is_number?(id) and id > 0 and id < 10000000
		return fetch_monster_by_id(id)
	elsif name.is_a?(String) and name.length > 0
		return fetch_monster_by_name(name)
	else
		return nil
	end
  end
  
  def user_voted_default_month(l,s)
	return user_voted_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  
  def user_voted_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).count > 0
  end
  
  def fetch_user_vote_by_default_month(l,s)
	return fetch_user_vote_by_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  def fetch_user_vote_by_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).order(created_at: :desc).first
  end
  
  def is_number? string
	true if Float(string) rescue false
  end
end
