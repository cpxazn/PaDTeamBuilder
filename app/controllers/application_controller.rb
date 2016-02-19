class ApplicationController < ActionController::Base
	helper_method :hash_not_nil, :fetch_monster_url_by_id_json, :censor_username, :censor_email, 
		:render_404, :user_voted_default_month, :fetch_user_vote_by_default_month, :rating_style, 
		:fetch_monster_by_id_json, :fetch_monster_by_name_json, :fetch_active_skill_by_id_json, 
		:fetch_leader_skill_by_id_json, :fetch_awakenings_by_id_json, :format_date,
		:round?
		
	before_filter :configure_permitted_parameters, if: :devise_controller?
	protect_from_forgery with: :exception
	after_filter :store_location

  def format_date(date)
	return date.localtime.strftime("%-m-%e-%Y %l:%M %p EST")
  end
	
	#Devise redirect back to last age
  def store_location
    # store last url as long as it isn't a /users path
	session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end
  def after_sign_in_path_for(resource)
	  session[:previous_url] || root_path
  end
  
  def hash_not_nil(hash, key)
	return hash != nil ? hash[key].to_s : ""
  end
  
  def render_404
	  respond_to do |format|
		format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
		format.xml  { head :not_found }
		format.any  { head :not_found }
	  end
	  return
  end
  
  def censor_username(username)
	u = username[0..0]
	for i in 1..username.length
		u = u + "*"
	end
	return u
	
  end
  def censor_email(email)
	e = email[0..0]
	for i in 1..email.index("@")-1
		e = e + "*"
	end
	for i in email.index("@")..email.length
		e = e + email[i..i]
	end
	return e
  end
  #Determines coloring based on the score
  def rating_style(rating)
	if rating >= 8
		return "success"
	elsif rating >= 6
		return "info"
	elsif rating >= 4
		return "warning"
	elsif rating >= 1
		return "danger"
	elsif rating == 0
		return "default"
	end
  end
  #Awoken Skills from JSON
  def fetch_awakenings_by_id_json(id)
	awakening_ids = fetch_monster_by_id_json(id)["awoken_skills"]
	awakenings = Rails.cache.fetch("awakenings")
	results = Array.new
	awakening_ids.each do |i|
		awakenings.each do |j|
			if i == j["id"]
				tmp = j.dup
				tmp["url"] = Rails.application.config.img_path_awakenings + i.to_s + ".png"
				results.push(tmp)
				break
			end
		end
	end
	return results
  end
  
  #Leader Skills from JSON
  def fetch_leader_skill_by_id_json(id)
	leader_skill_name = fetch_monster_by_id_json(id)["leader_skill"]
	leader_skills = Rails.cache.fetch("leader_skills")
	leader_skills.each do |l|
		if l["name"].to_s == leader_skill_name.to_s
			return l
			break
		end
	end
	return nil
  end
  
  #Active Skills from JSON
  def fetch_active_skill_by_id_json(id)
	active_skill_name = fetch_monster_by_id_json(id)["active_skill"]
	active_skills = Rails.cache.fetch("active_skills")
	active_skills.each do |s|
		if s["name"].to_s == active_skill_name.to_s
			return s
			break
		end
	end
	return nil
  end
  #Fetch Monster IMG URL from JSON
  def fetch_monster_url_by_id_json(id)
	return fetch_monster_by_id_json(id)["image60_href"]
  end
  #Monster from JSON
  def fetch_monster_by_id_json(id)
  	monsters = Rails.cache.fetch("monster")
	monsters.each do |m|
		if m["id"].to_s == id.to_s
			return m
			break
		end
	end
	return nil
  end
  def fetch_monster_by_name_json(name)
  	monsters = Rails.cache.fetch("monster")
	monsters.each do |m|
		if m["name"].to_s == name.to_s
			return m
			break
		end
	end
	return nil
  end
 
  def create_monster(id, name)
	if id == nil and name == nil then return nil end
	if name == nil and id != nil then 
		name = fetch_monster_by_id_json(id)
		if name == nil then return nil end
	elsif id == nil and name != nil
		id = fetch_monster_by_name_json(name)
		if id == nil then return nil end
	end
    return Monster.create(id: id, name: name)
  end
  
 #Monster from DB
  def fetch_monster_by_id(id)
		if Monster.where(id: id).count == 1
			return Monster.find(id)
		else
			return create_monster(id, nil)
		end			
  end
  def fetch_monster_by_name(name)
		if Monster.where(name: name).count > 0
			return Monster.where(name: name).first
		else
			m = fetch_monster_by_name_json(name)
			return m != nil ? create_monster(hash_not_nil(m,"id"), hash_not_nil(m,"name")) : nil
		end
  end
  #Monster from DB using either id or name depending on which one has value
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
  
  #Return true/false if user has voted
  def user_voted_default_month(l,s)
	return user_voted_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  
  def user_voted_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).count > 0
  end
  #Gets vote for the current user for the monster
  def fetch_user_vote_by_default_month(l,s)
	return fetch_user_vote_by_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  def fetch_user_vote_by_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).order(created_at: :desc).first
  end
  
  #Generic functions
  def is_number? string
	true if Float(string) rescue false
  end
  def round? i
	return i.to_i == i ? i.to_i : i
  end
  
	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me, :padherder) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :padherder) }
	end
	

end
