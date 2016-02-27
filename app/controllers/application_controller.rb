class ApplicationController < ActionController::Base

	before_filter :configure_permitted_parameters, if: :devise_controller?
	protect_from_forgery with: :exception
	after_filter :store_location

#Monster functions
  #Populate default tag
  #Input: monster id
  #Output: monster object
  def populate_default_monster_tag(id)
	monster = fetch_monster_by_id(id)
	monster_json = fetch_monster_by_id_json(id)
	
	#Element
	element = Array.new
	if monster_json["element"] != nil then element.push(monster_json["element"]) end
	if monster_json["element2"] != nil then element.push(monster_json["element2"]) end
		element.each do |e|
		case e
			when 0
				monster.tag_list.add("fire")
			when 1
				monster.tag_list.add("water")
			when 2
				monster.tag_list.add("wood")
			when 3
				monster.tag_list.add("light")
			when 4
				monster.tag_list.add("dark")
		end
	end
	type = Array.new
	if monster_json["type"] != nil then type.push(monster_json["type"]) end
	if monster_json["type2"] != nil then type.push(monster_json["type2"]) end
	if monster_json["type3"] != nil then type.push(monster_json["type3"]) end	
	type.each do |t|
		case t
			when 0
				monster.tag_list.add("evo material")
			when 1
				monster.tag_list.add("balanced")
			when 2
				monster.tag_list.add("physical")
			when 3
				monster.tag_list.add("healer")
			when 4
				monster.tag_list.add("dragon")
			when 5
				monster.tag_list.add("god")
			when 6
				monster.tag_list.add("attacker")
			when 7
				monster.tag_list.add("devil")
			when 8
				monster.tag_list.add("machine")
			when 12
				monster.tag_list.add("awoken skill material")
			when 13
				monster.tag_list.add("protected")
			when 14
				monster.tag_list.add("enhance material")
		end
	end	
	awakenings = fetch_awakenings_by_id_json(monster_json["id"])
	awakenings.each do |a|
		if a["id"] >= 4
			monster.tag_list.add(a["name"])
		end
	end
	
	monster.save

	return monster.tag_list
  end
  
  #Search monster by name
  #Input: partial or full monster name as string
  #Output: array of json hash that matches input name
  def search_monster_by_name_json(name)
	monsters = Rails.cache.fetch("monster")
	result = Array.new
	monsters.each do |m|
		if m["name"].upcase.include? name
			temp = Hash.new
			temp["name"] = m["name"]
			temp["id"] = m["id"]
			temp["img_url"] = m["image60_href"]
			result.push(temp)
		end
	end
	return result
  end
  #Awoken Skills from JSON
  #Input: monster id as integer
  #Output: hash of awakenings
  helper_method :fetch_awakenings_by_id_json
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
  #Leader Skill from JSON
  #Input: monster id as integer
  #Output: hash of leader skill
  helper_method :fetch_leader_skill_by_id_json
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
  #Input: monster id as integer
  #Output: hash of active skill
  helper_method :fetch_active_skill_by_id_json
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
  #Input: monster id as integer
  #Output: image url as string
  helper_method :fetch_monster_url_by_id_json
  def fetch_monster_url_by_id_json(id)
	return fetch_monster_by_id_json(id)["image60_href"]
  end
  #Monster from JSON by ID
  #Input: monster id as integer
  #Output: hash of monster
  helper_method :fetch_monster_by_id_json
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
  #Monster from JSON by name
  #Input: name as string
  #Output: hash of monster
  helper_method :fetch_monster_by_name_json
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
  #Create monster from JSON info
  #Input: either ID or name
  #Output: newly created monster
  helper_method :create_monster
  def create_monster(id, name)
	if id == nil and name == nil then return nil end
	if name == nil and id != nil then 
		name = fetch_monster_by_id_json(id)
		if name == nil then return nil end
		name = name["name"]
	elsif id == nil and name != nil
		id = fetch_monster_by_name_json(name)
		if id == nil then return nil end
		id = id["name"]
	end
    return Monster.create(id: id, name: name)
  end
  #Monster from DB by ID
  #Input: id as integer
  #Output: monster
  helper_method :fetch_monster_by_id
  def fetch_monster_by_id(id)
		if Monster.where(id: id).count == 1
			return Monster.find(id)
		else
			return create_monster(id, nil)
		end			
  end
  #Get array from JSON
  #Input: Array of Monster objects
  #Output: Array of Hash of Monsters from JSON
  def fetch_monster_json_by_array(arr)
	if arr != nil and arr.size > 0
		results = Array.new
		arr.each do |m|
			results.push(fetch_monster_by_id_json(m.id))
		end
		return results
	end
	return nil
  end
  #Monster from DB by name
  #Input: name as string
  #Output: monster
  helper_method :fetch_monster_by_name
  def fetch_monster_by_name(name)
		if Monster.where(name: name).count > 0
			return Monster.where(name: name).first
		else
			m = fetch_monster_by_name_json(name)
			return m != nil ? create_monster(hash_not_nil(m,"id"), hash_not_nil(m,"name")) : nil
		end
  end
  #Monster from DB using either id or name depending on which one has value
  #Input: id or name
  #Output: monster
  helper_method :fetch_monster_by_one
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

#Vote Functions
  #Return true/false if user has voted in the past X months
  #Input: leader id as integer, sub id as integer
  #Output: boolean
  helper_method :user_voted_default_month
  def user_voted_default_month(l,s)
	return user_voted_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  helper_method :user_voted_month
  def user_voted_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).count > 0
  end
  
  #Gets vote for the current user for the monster
  #Input: leader id as integer, sub id as integer
  #Output: score as float
  helper_method :fetch_user_vote_by_default_month
  def fetch_user_vote_by_default_month(l,s)
	return fetch_user_vote_by_month(l,s,Rails.application.config.vote_new_user_interval)
  end
  helper_method :fetch_user_vote_by_month
  def fetch_user_vote_by_month(l,s,m)
	return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).order(created_at: :desc).first
  end
  
  #Determines coloring based on the score
  #Input: score as integer
  #Output: string
  helper_method :rating_style
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
  

#Generic functions
  #Format time ago in words
  #Input: date
  #Output: string
  helper_method :time_ago
  def time_ago(d)
	result = view_context.time_ago_in_words(d)
	return result == "less than a minute" ? "< 1 minute" : result
  end
  #Check if string contains only numbers
  #Input: string
  #Output: boolean
  helper_method :is_number?
  def is_number? string
	true if Float(string) rescue false
  end
  #Only round if needed
  #Input: number
  #Output: integer/float
  helper_method :round?
  def round? i
	return i.to_i == i ? i.to_i : i
  end
  #Checks if a hash is nil or not. If it is, then return an empty string.
  #Input: hash, key as string
  #Output: string
  helper_method :hash_not_nil
  def hash_not_nil(hash, key)
	return hash != nil ? hash[key].to_s : ""
  end
  #Checks if object is nil or not. If it is, then return an empty string.
  #Input: string from object
  #Output: string
  helper_method :not_nil
  def not_nil(obj)
	return if obj == nil ? "" : obj
  end
  #Returns formatted local date to be used in the view
  #Input: date
  #Output: string
  helper_method :format_date
  def format_date(date)
	return date.localtime.strftime("%-m-%e-%Y %l:%M %p EST")
  end
    #Censors all but the first letter of the username
  #Input: string
  #Output: string
  def censor_username(username)
	u = username[0..0]
	for i in 1..username.length
		u = u + "*"
	end
	return u
  end
  #Censors all but the first letter of the email address and domain
  #Input: string
  #Output: string
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
  #Renders 404 page
  helper_method :render_404
  def render_404
	  respond_to do |format|
		format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
		format.xml  { head :not_found }
		format.any  { head :not_found }
	  end
	  return
  end
  
#Devise
  #Devise redirect back to last age
  def store_location
    # store last url as long as it isn't a /users path
	session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/ or request.fullpath =~ /\/json/ or request.fullpath =~ /\/static/
	
  end
  def after_sign_in_path_for(resource)
	  session[:previous_url] || root_path
  end

  protected
  def configure_permitted_parameters
	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me, :padherder) }
	devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
	devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :padherder) }
  end
	

end
