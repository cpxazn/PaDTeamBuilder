class ApplicationController < ActionController::Base

	before_filter :configure_permitted_parameters, if: :devise_controller?
	protect_from_forgery with: :exception
	after_filter :store_location

#Monster functions
  def tag_update2
	if current_user.username == 'cpxazn'
		monsters = Rails.cache.fetch("monster")
		monsters.each do |m|
			populate_default_monster_tag(m["id"])
		end
		populate_default_monster_tag(2076)
	end
	redirect_to monsters_path
  end
  #Generates detailed tooltip with tags and skills
  #Input: monster id 1, monster id 2
  #Output: String
  helper_method :detailed_tooltip
  def detailed_tooltip(id1, id2, t)
	active_skill = fetch_active_skill_by_id_json(id1)
	if active_skill != nil
		active_skill = active_skill["effect"] + " (" + hash_not_nil(@active_skill,"max_cooldown") + " to " + hash_not_nil(@active_skill,"min_cooldown") + " turns)"
	else
		active_skill = ""
	end
	leader_skill = fetch_leader_skill_by_id_json(id1)
	if leader_skill != nil then leader_skill = leader_skill["effect"] else leader_skill = "" end
	
	results = ""
	results = results + Monster.find(id1).tooltip
	results = results + "&#13;Active Skill: " + active_skill
	results = results + "&#13;Leader Skill: " + leader_skill
	results = results + "&#13;&#13;Tags: " + Monster.find(id1).tag_delim
	if id2 != nil and t != nil then
		if t == "leader"
			results = results + "&#13;Pairing Specific Tags: " + Monster.find(id1).tag_delim_pair(id2, "ls")
		elsif t == "sub"
			results = results + "&#13;Pairing Specific Tags: " + Monster.find(id2).tag_delim_pair(id1, "ls")
		else
			results = results + "&#13;Pairing Specific Tags: " + Monster.find(id2).tag_delim_pair(id1, t)
		end
	end
	results = results.html_safe
  end
  
  #Populate default tag
  #Input: monster id
  #Output: monster object
  def populate_default_monster_tag(id)
	monster = fetch_monster_by_id(id)
	monster_json = fetch_monster_by_id_json(id)
	
	#Element
	if monster_json["element"] != nil
		e = monster_json["element"]
		case e
			when 0
				monster.tag_list.add("attr main: fire")
				monster.tag_list.add("attr: fire")
			when 1
				monster.tag_list.add("attr main: water")
				monster.tag_list.add("attr: water")
			when 2
				monster.tag_list.add("attr main: wood")
				monster.tag_list.add("attr: wood")
			when 3
				monster.tag_list.add("attr main: light")
				monster.tag_list.add("attr: light")
			when 4
				monster.tag_list.add("attr main: dark")
				monster.tag_list.add("attr: dark")
		end	
	end
	if monster_json["element2"] != nil
		e = monster_json["element2"]
		case e
			when 0
				monster.tag_list.add("attr sub: fire")
				monster.tag_list.add("attr: fire")
			when 1
				monster.tag_list.add("attr sub: water")
				monster.tag_list.add("attr: water")
			when 2
				monster.tag_list.add("attr sub: wood")
				monster.tag_list.add("attr: wood")
			when 3
				monster.tag_list.add("attr sub: light")
				monster.tag_list.add("attr: light")
			when 4
				monster.tag_list.add("attr sub: dark")
				monster.tag_list.add("attr: dark")
		end	
	end

	#Rarity
	if monster_json["rarity"] != nil
		if monster_json["rarity"] <= 4
			monster.tag_list.add("rarity: under 5")
		elsif monster_json["rarity"] > 5
			monster.tag_list.add("rarity: over 5")
		end
		monster.tag_list.add("rarity: " + monster_json["rarity"].to_s)
	end
	
	#Type
	type = Array.new
	if monster_json["type"] != nil then type.push(monster_json["type"]) end
	if monster_json["type2"] != nil then type.push(monster_json["type2"]) end
	if monster_json["type3"] != nil then type.push(monster_json["type3"]) end	
	type.each do |t|
		case t
			when 0
				monster.tag_list.add("type: evo material")
			when 1
				monster.tag_list.add("type: balanced")
			when 2
				monster.tag_list.add("type: physical")
			when 3
				monster.tag_list.add("type: healer")
			when 4
				monster.tag_list.add("type: dragon")
			when 5
				monster.tag_list.add("type: god")
			when 6
				monster.tag_list.add("type: attacker")
			when 7
				monster.tag_list.add("type: devil")
			when 8
				monster.tag_list.add("type: machine")
			when 12
				monster.tag_list.add("type: awoken skill material")
			when 13
				monster.tag_list.add("type: protected")
			when 14
				monster.tag_list.add("type: enhance material")
		end
	end	
	
	#Awakenings
	awakenings = fetch_awakenings_by_id_json(monster_json["id"])
	awakenings.each do |a|
		#if a["id"] >= 4
			monster.tag_list.add("awoken skill: " + a["name"])
		#end
	end
	
	#Active Skills
	active_skill = fetch_active_skill_by_id_json(monster_json["id"])
	if active_skill != nil then
		active_skill_effect = active_skill["effect"].downcase
		active_skill_group = {
			"ATK" => "ATK x",
			"RCV" => "RCV x",
			"ATK Buff" => "attribute cards ATK x",
			"ATK Buff" => "attribute ATK x",
			"ATK Buff" => "type cards ATK x",
			"Fire" => "Fire",
			"Water" => "Water",
			"Wood" => "Wood",
			"Light" => "Light",
			"Dark" => "Dark",
			"Block" => "Block",
			"Poison" => "Poison orbs",
			"Dragon" => "Dragon",
			"Balanced" => "Balanced",
			"Physical" => "Physical",
			"Healer" => "Healer", 
			"Attacker" => "Attacker",
			"God" => "God",
			"Devil" => "Devil",
			"Gravity" => "all enemies' HP",
			"Change" => "Change",
			"Change board" => "Change all orbs",
			"Change attr" => "Change own attribute",
			"Enhance Orbs" => "Enhance",
			"Delay" => "Delay",
			"Recover" => "Recover",
			"Poison Damage" => "Poison damage",
			"Skyfall" => "skyfall",
			"Damage Reduction" => "damage reduction",
			"Defense Reduction" => "Reduce enemies' defense",
			"Avoid Damage" => "Avoid all",
			"Multi-Target" => "become multi-target",
			"Counter" => "Counter",
			"Deal" => "Deal", 
			"1 Enemy" => "1 enemy",
			"All Enemies" => "all enemies",
			"Stop Time" => "without triggering matches",
			"Reduce HP to 1" => "reducing HP to 1",
			"Grudge" => "based on player's HP",
			"Reshuffle" => "Reshuffle",
			"Drain" => "drain",
			"Switch Leader" => "Switch places with leader",
			"Random Skill" => "Activate a random skill",
			"Haste" => "Reduces cooldown",
			"Spawn" => "Randomly spawn",
			"Bind Recovery" => "Bind recovery",
			"Time Extend" => "Increases time limit of orb",
			"Change Orbs - Locked" => "into locked orbs"
		}
		active_skill_group.each do |key, value|
			if active_skill_effect.include? value.downcase
				if key.downcase.include? "change" and active_skill_effect.split.include? 'change' and active_skill_effect.include? "orb" #if active is an orb change and current skill lookup is change
					if active_skill_effect.split.include? "exchange"
						tmp0 = active_skill_effect.gsub 'exchange', '' 
					else
						tmp0 = active_skill_effect
					end
					 
					#Find the position of the word "change"
					#Ignore change own attribute
					if active_skill_effect.include? 'change own attr'
						change_index = tmp0.index('change')
						change_index2 = tmp0.index('change own attr')
						if change_index == change_index2 then
							change_index = tmp0.index('change', change_index2 + 6)
						end
					else
						change_index = tmp0.index('change')
					end

					#If it is not a board change
					if key.downcase != "change board" and not active_skill_effect.include? 'change all' and change_index != nil
						tmp1 = tmp0.last(active_skill_effect.length - (change_index+7)) #Get all characters after the word change
						tmp2 = tmp1.split(".")[0] #entire orb change string
						change_count = tmp2.scan(/to/).count
						if change_count > 1 and tmp2.include? "," #if there are two orb changes
							tmp3 = tmp2.split(", ")
						elsif change_count > 1 and tmp2.include? " and the "
							tmp3 = tmp2.split(" and the ")
						elsif change_count > 1 and tmp2.include? " and "
							tmp3 = tmp2.split(" and ")
						else
							tmp3 = [tmp2]
						end

						tmp3.each do |i| #go through all orb changes
							tmp4 = i.gsub ' orbs', '' #remove the word orbs
							if tmp4.include? " into "
								tmp5 = tmp4.split(' into ') #split "into"
							elsif tmp4.include? " to "
								tmp5 = tmp4.split(' to ') #split "to"
							end
							to = tmp5[1] #will be the words on the right of "to"
							tmp6 = tmp5[0] #will be the words on the left of "to"

							if tmp6.include? " & " or tmp6.include? "," #if there is a double orb change to a single color
								if tmp6.include? " &" then 
									tmp7 = tmp6.gsub ' &', ','
								else
									tmp7 = tmp6
								end
								from = tmp7.split(", ") #split the values of the "from"
								monster.tag_list.add("active skill: multi orb change") #add tag for double orb change
							else
								from = [tmp6] #otherwise give array with one "from"
							end
							from.each do |j|
								monster.tag_list.add("active skill: change orbs - " + j + " to " + to)
								monster.tag_list.add("active skill: change orbs - " + to)
							end
						end					
					elsif change_index != nil and key.downcase == "change board"
						tmp1 = tmp0.last(active_skill_effect.length - (change_index+7)) #Get all characters after the word change
						tmp2 = tmp1.split("to ")[1]
						tmp3 = tmp2.split(" orbs")[0]
						if tmp3.include? "&" then tmp4 = tmp3.gsub! '&', ',' else tmp4 = tmp3 end
						if tmp4.include? " " then tmp5 = tmp4.gsub! ' ', '' else tmp5 = tmp4 end
						tmp6 = tmp5.split(",")
						color_count = tmp6.count
						if color_count > 0 then monster.tag_list.add("active skill: change board - " + color_count.to_s + " colors") end
						tmp6.each do |i|
							monster.tag_list.add("active skill: change board - " + i)
						end
					end
				end
				monster.tag_list.add("active skill: " + key.downcase)
			end
		end
	end
	
	#Leader Skills
	leader_skill = fetch_leader_skill_by_id_json(monster_json["id"])
	if leader_skill != nil then
		leader_skill_effect = leader_skill["effect"].downcase
		leader_skill_group = { 
			"HP Multiplier" => "HP x", 
			"ATK Multiplier" => "ATK x", 
			"RCV Multiplier" => "RCV x", 
			"Fire" => "Fire", 
			"Water" => "Water", 
			"Wood" => "Wood", 
			"Light" => "Light", 
			"Dark" => "Dark", 
			"All attr" => "all attr", 
			"HP Conditional" => "when HP is", 
			"Dragon" => "Dragon", 
			"Balanced" => "Balanced", 
			"Physical" => "Physical", 
			"Healer" => "Healer", 
			"Attacker" => "Attacker", 
			"God" => "God", 
			"Devil" => "Devil", 
			"Enhance Material" => "Enhance Material", 
			"Damage Reduction" => "damage reduction", 
			"Color Match" => "when attacking with", 
			"Combo" => "combo", 
			"Scaling Match" => "for each additional", 
			"Connected" => "connected", 
			"Auto Heal" => "HP after every orbs elimination", 
			"Auto Damage" => "enemies after every orbs elimination", 
			"Perseverance" => "leave you with 1", 
			"Extend Time" => "orb movement", 
			"Counter" => "counter", 
			"Coins" => "coin", 
			"Buff from Using Active Skill" => "on the turn a skill is used",
			"Sub Dependency" => "in the same team",
			"Enhanced orb" => "enhanced orb"
		}
		leader_skill_group.each do |key, value|
			if leader_skill_effect.include? value.downcase
			
				#Color Match
				if key.downcase == "color match"
					if leader_skill_effect.include? "following orb types:"
						tmp0 = leader_skill_effect.split(" following orb types: ")[1]
						
						temp0 = leader_skill_effect.split(" following orb types: ")[0]
						color_count = temp0.split("when attacking with ")[1].to_i
						
						tmp1 = tmp0.split(".")[0]
						type = 0 #When attacking with all colors
					else
						tmp0 = leader_skill_effect.split("when attacking with ")[1]
						tmp1 = tmp0.split(" orb")[0]
						type = 1 #When attacking with some colors
					end
						
					if tmp1.include? " & "
						tmp2 = tmp1.gsub(' &', ',')
					else
						tmp2 = tmp1
					end
					
					if tmp2.include? ", "
						tmp3 = tmp2.split(", ")
					else
						tmp3 = [tmp2]
					end
					
					if type == 1 then color_count = tmp3.count end
					
					if color_count > 0 then monster.tag_list.add("leader skill: color match - " + color_count.to_s + " colors") end
					
					tmp3.each do |i|
						monster.tag_list.add("leader skill: color match - " + i)
					end	
				end
				
				monster.tag_list.add("leader skill: " + key.downcase)
			end
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
	m = Monster.create(id: id, name: name)
	tags = populate_default_monster_tag(id)
    return m
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
  def user_voted_default_month(l,s,t)
	return user_voted_month(l,s,Rails.application.config.vote_new_user_interval,t)
  end
  helper_method :user_voted_month
  def user_voted_month(l,s,m,t)
	case t
		when "ls"
			return current_user.votes.where("leader_id = ? and sub_id = ? and created_at > ?", l,s, m.month.ago).count > 0
		when "ll"
			return current_user.vote_lls.where("? = ANY(leaders) and ? = ANY(leaders) and created_at > ?", l,s, m.month.ago).count > 0
		else
			return false
	end
  end
  
  
  #Gets vote for the current user for the monster
  #Input: leader id as integer, sub id as integer
  #Output: score as float
  helper_method :fetch_user_vote_by_default_month
  def fetch_user_vote_by_default_month(m1,m2,t)
	return fetch_user_vote_by_month(m1,m2,Rails.application.config.vote_new_user_interval,t)
  end
  helper_method :fetch_user_vote_by_month
  def fetch_user_vote_by_month(m1,m2,mnth,t)
	return Monster.model_gen(t).where(Monster.query_gen(t, m1, m2) + "and user_id = ? and created_at > ?", m1,m2, current_user.id, mnth.month.ago).order(created_at: :desc).first
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
	return date.localtime.strftime("%-m/%-d/%Y %l:%M %p EST")
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
  
  #Remember last location for devise redirect
  def after_sign_in_path_for(resource)
	  session[:previous_url] || root_path
  end

  protected
  #Devise parameters
  def configure_permitted_parameters
	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me, :padherder) }
	devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
	devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :padherder) }
  end
	

end
