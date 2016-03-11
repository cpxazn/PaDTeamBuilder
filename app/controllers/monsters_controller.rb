class MonstersController < ApplicationController
  require 'open-uri'
  require 'open_uri_redirections'
  before_action :cache_data
  #before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :fetch_both, only: [:detail, :graph_since_json, :graph_monthly_json, :graph_count_json, :graph_weight_json, :graph_json ]
  before_action :authenticate_user!, only: [:add_tag, :add_pair_tag, :tag_update]
  respond_to :html
  
  def questionable
	Rails.cache.fetch("questionable_outliers", expires_in: 15.minutes) do
			Vote.outliers(Rails.application.config.vote_display_default, "ls")
	end
	Rails.cache.fetch("questionable_low_count", expires_in: 15.minutes) do
			Vote.low_count(Rails.application.config.vote_display_default, "ls")
	end
	Rails.cache.fetch("questionable_low_rating", expires_in: 15.minutes) do
			Vote.low_rating(Rails.application.config.vote_display_default, "ls")
	end
	Rails.cache.fetch("questionable_low_rarity", expires_in: 15.minutes) do
			Vote.find_monster_in(fetch_low_rarity_json, Rails.application.config.vote_display_default, "ls")
	end
	#@outliers = Vote.outliers(Rails.application.config.vote_display_default, "ls")
	#@low_count = Vote.low_count(Rails.application.config.vote_display_default, "ls")
	#@low_rating = Vote.low_rating(Rails.application.config.vote_display_default, "ls")
	@outliers = Rails.cache.fetch("questionable_outliers")
	@low_count = Rails.cache.fetch("questionable_low_count")
	@low_rating = Rails.cache.fetch("questionable_low_rating")
	@low_rarity = Rails.cache.fetch("questionable_low_rarity")
  end
  def fetch_low_rarity_json
	monsters = Rails.cache.fetch("monster")
	results = Array.new
	monsters.each do |m|
		if m["rarity"] < 5 then results.push(m["id"]) end
	end
	return results
  end
  
  def image_proxy
	remote_url = Rails.application.config.img_path_monsters + "#{request.path}"
	local_url = "public#{request.path}"
  
	if not File.exist? local_url
		IO.copy_stream(open(remote_url, :allow_redirections => :safe), local_url)
	end
 
	send_file local_url, type: 'image/png', disposition: 'inline'
  end
	
  def search
	@title = "Tags"
	@tags = ActsAsTaggableOn::Tag.order(taggings_count: :desc)
	@selected = params[:tags]
	if @selected != nil and @selected.size > 0
		monsters = Monster.tagged_with(@selected, :on => :tags)
		@monsters = fetch_monster_json_by_array(monsters)
		if @monsters != nil then @monsters = @monsters.sort_by { |hash| hash['element'].to_i } end 
	end
  end
  
  def index
	@title = "Summary"
	@latestVotes = Vote.order(created_at: :desc).limit(Rails.application.config.fp_display_max_monsters)
	@latestVotesLl = VoteLl.order(created_at: :desc).limit(Rails.application.config.fp_display_max_monsters)
	
	topMonstersArray = Vote.recent_top(Rails.application.config.vote_display_default)
	@topMonsters = Array.new
	topMonstersArray.each do |m|
		@topMonsters.push([fetch_monster_by_id(m[0]),m[1]])
	end
	
	@topUsers = User.top
	@latestComments = Comment.latest
	@latestCommentsLl = CommentLl.latest
  end
  
  #Shows a particular monster from JSON. Input parameter is params[:id]
  def show
	@monster = fetch_monster_by_id(params[:id])

	#Make sure monster was fetched
	if @monster != nil
		update_monster_name_with_json(@monster)
		@monster.url = fetch_monster_url_by_id_json(@monster.id)
		
		@title = @monster.id.to_s
		
		@subs = Array.new
		#Get suggested subs
		@subs_list = @monster.subs
		@subs_list = @subs_list.sort_by { | x | x[:score] }.reverse
		@subs_list.each do |s|
			sub = fetch_monster_by_id(s[:id])
			if sub != nil
				sub.avg = round?(s[:score])
				sub.avg_count = @monster.vote_count(sub.id,"ls")
				sub.url = fetch_monster_url_by_id_json(sub.id)
				if user_signed_in? and user_voted_default_month(@monster.id,sub.id,"ls")
					sub.user_score = fetch_user_vote_by_default_month(@monster.id, sub.id,"ls").score
				end
				@subs.push(sub)
			end
		end
		
		@leaders = Array.new
		#Get suggested leaders
		@leaders_list = @monster.leaders
		@leaders_list = @leaders_list.sort_by { | x | x[:score] }.reverse
		@leaders_list.each do |l|
			leader = fetch_monster_by_id(l[:id])
			if leader != nil
				leader.avg = round?(l[:score])
				leader.avg_count = leader.vote_count(@monster.id,"ls")
				leader.url = fetch_monster_url_by_id_json(leader.id)
				if user_signed_in? and user_voted_default_month(leader.id,@monster.id,"ls")
					leader.user_score = fetch_user_vote_by_default_month(leader.id,@monster.id,"ls").score
				end
				@leaders.push(leader)
			end
		end
		
		@ll = Array.new
		@ll_list = @monster.ll_list
		@ll_list = @ll_list.sort_by { | x | x[:score] }.reverse
		@ll_list.each do |l|
			leader = fetch_monster_by_id(l[:id])
			if leader != nil
				leader.avg = round?(l[:score])
				leader.url = fetch_monster_url_by_id_json(leader.id)
				leader.avg_count = @monster.vote_count(leader.id,"ll")
				if user_signed_in? and user_voted_default_month(@monster.id,leader.id,"ll")
					leader.user_score = fetch_user_vote_by_default_month(@monster.id,leader.id,"ll").score
				end
				@ll.push(leader)
			end
		end
		
		#Get other details
		@active_skill = fetch_active_skill_by_id_json(@monster.id)
		@leader_skill = fetch_leader_skill_by_id_json(@monster.id)
		@awakenings = fetch_awakenings_by_id_json(@monster.id)
		@related = append_monster_url(get_all_evo(@monster.id))
	else
		render_404; return;
	end
	
    respond_with(@monster)
  end
  #Gets rating details, passes to modale or actual view
  def detail
	
	if @sub != nil and @leader != nil
		@title = "Details"
		@score = @leader.score(@sub.id,@type);
		@votes = @leader.vote_count(@sub.id, @type);
		@score_all = @leader.fetch_score_all(@sub.id, @type);
		@votes_all = @leader.fetch_vote_count_all(@sub.id, @type);
		@comments = Comment.model_gen(@type).sorted(@leader.id, @sub.id)
		respond_to do |format|
			format.html
			format.js
		end
	end
  end
 
  def add_pair_tag
	new_tags = params[:tags]
	m1_id = params[:monster_id]
	m2_id = params[:m2_id]
	type = params[:type]
	m2 = fetch_monster_by_id(m2_id)
	m1 = fetch_monster_by_id(m1_id)
	context = type + "_" + m2_id.to_s
	if new_tags == nil then new_tags = [] end
	if m1 != nil and m2 != nil
		old_tags = m1.tag_list_on(context).dup
		if old_tags == nil then old_tags = [] end
		old_tags.each do |old|
			found = 0
			new_tags.each do |new|
				if old == new then 
					found = 1 
				end
			end
			if found == 0 then 
				m1.tag_list_on(context).remove(old) 
			end
		end
		old_tags = m1.tag_list_on(context).dup
		new_tags.each do |new|
			found = 0
			old_tags.each do |old|
				if new == old then found = 1 end
			end
			if found == 0 then 
				if new.length <= Rails.application.config.tag_max_length 
					m1.tag_list_on(context).add(new) 
				else
					flash.now[:alert] = 'Error: One or more tags could not be saved due to length limitation: ' + Rails.application.config.tag_max_length.to_s 
				end
			end
		end
		m1.save
		m1.reload
		@tags = m1.tag_list_on(context)
	end
	respond_to do |format|
		format.js
	end
  end
  def add_tag
	new_tags = params[:tags]
	monster_id = params[:monster_id]
	monster = fetch_monster_by_id(monster_id)
	if new_tags == nil then new_tags = [] end
	if monster != nil
		old_tags = monster.tag_list.dup
		if old_tags == nil then old_tags = [] end
		old_tags.each do |old|
			found = 0
			new_tags.each do |new|
				if old == new then found = 1 end
			end
			if found == 0 then 
				monster.tag_list.remove(old) 
			end
		end
		old_tags = monster.tag_list.dup
		new_tags.each do |new|
			found = 0
			old_tags.each do |old|
				if new == old then found = 1 end
			end
			if found == 0 then 
				if new.length <= Rails.application.config.tag_max_length 
					monster.tag_list.add(new)
				else
					flash.now[:alert] = 'Error: One or more tags could not be saved due to length limitation: ' + Rails.application.config.tag_max_length.to_s
				end
			end
		end
		
		monster.save
		monster.reload
		@tags = populate_default_monster_tag(monster.id)
	end
	respond_to do |format|
		format.js
	end
  end
  
#JSON
  #Tags
  def tags_json
	name = params[:name]
	results = Array.new
	if name != nil
		ActsAsTaggableOn::Tag.all.each do |t|
			if t.name.downcase.include? name.downcase
				results.push(t)
			end
		end
	else
		results = ActsAsTaggableOn::Tag.all
	end

	render :json => results
  end
  
  #Gets monster parameters for typeahead
  def typeahead_json
	monster = monster_name_json_params
	results = search_monster_by_name_json(monster.upcase)
	render :json => results
  end
  def subs_json
	subs = Monster.find(params.require(:id)).subs
	render :json => subs.sort_by { | x | x[:score] }.reverse[0..10]
  end
  #Graphs
  def graph_json
	if params["graph"] == nil
		render_404; return;
	else
		@graph = params["graph"]
	end
	if params["type"] == nil
		render_404; return;
	else
		@type = params["type"]
	end
	data = Array.new

	case @graph
		when "count"
			data.push("Ratings")
		when "monthly"
			data.push("Avg By Month")
		when "since"
			data.push("Avg Since")
		when "weighted"
			data.push("Weighted Avg")
	end
	if data.length > 0
		tmp2 = Array.new
		for i in (Rails.application.config.vote_display_max).downto(0)
			tmp = Array.new
			j = i + 1
			Rails.application.config.vote_display_eom ? tmp.push(j.month.ago.strftime("%Y-%m-1")) : tmp.push(j.month.ago.strftime("%Y-%m-%d"))
			case @graph
				when "count"
					tmp.push(@leader.fetch_vote_count_by_month(@sub.id, i, @type))
				when "monthly"
					tmp.push(@leader.fetch_score_by_month(@sub.id, i, @type))
				when "since"
					tmp.push(@leader.fetch_score_ago_beg(@sub.id, i, @type))
				when "weighted"
					tmpData = @leader.fetch_weighted_avg(@sub.id, i, @type)
					if tmpData.is_a?(Float) && tmpData.nan?
						tmp.push(0)
					else
						tmp.push(tmpData)
					end
			end
			tmp2.push(tmp)
		end
		data.push(tmp2);
	end
	render :json => data
  end
  
#Others
  #Initial tag population of all monsters
  def tag_update
	if current_user.username == 'cpxazn'
		monsters = Rails.cache.fetch("monster")
		monsters.each do |m|
			populate_default_monster_tag(m["id"])
		end
	end
	redirect_to monsters_path
  end
  
  private
	def update_monster_name_with_json(m)
		monster_json = fetch_monster_by_id_json(m.id)
		if monster_json != nil and monster_json["name"] != m.name then
			m.name = monster_json["name"]
			m.save
		end
	end
    def append_monster_url(arrMonsters)
		if arrMonsters != nil
			arrMonsters.each do |m|
				m.url = fetch_monster_url_by_id_json(m.id)
			end
			return arrMonsters
		else
			return nil
		end
	end
  	def get_base_evo(id)
		evos = Rails.cache.fetch("evolutions")
		last = id
		current = id
		dupe = Array.new
		while current != 0 do
			evos.each do |item|
				current = 0
				evos[item[0].to_s].each do |e|
					if e["evolves_to"] == last and not dupe.include?(item[0].to_i)
						current = item[0].to_i
						dupe.push(current)
						break
					end
				end
				if current != 0
					last = current
					break
				end
				
			end
		end
		return last	
	end
	def get_next_evo(id)
		results = Array.new
		evos = Rails.cache.fetch("evolutions")[id.to_s]
		if evos != nil
			evos.each do |e|
				results.push(e["evolves_to"])
			end
		end
		results
	end
	def get_all_evo(id)
		results = Array.new
		traverse_evo(get_base_evo(id), 0, results)
	end
	def traverse_evo(id, level, results)
		
		if not results.include?(fetch_monster_by_id(id))
			results.push(fetch_monster_by_id(id))
			get_next_evo(id).each do |m|
				traverse_evo(m, level + 1, results)
			end
		end
		return results
	end
    def fetch_both
		if params["sub_id"] == nil or params["leader_id"] == nil or params["type"] == nil or (params["type"] != "ll" and params["type"] != "ls") then render_404; return; end
		@type = params["type"]
		@sub = fetch_monster_by_id(params["sub_id"])
		@leader = fetch_monster_by_id(params["leader_id"])
		#if @sub == nil then create(params["sub_id"],nil) end
		#if @leader == nil then create(params["leader_id"],nil) end
		if @sub == nil or @leader == nil then render_404; return; end
		@sub_details = fetch_monster_by_id_json(@sub.id)
		@leader_details = fetch_monster_by_id_json(@leader.id)
	end
    def set_monster
		@monster = Monster.find(params[:id])
    end
	def monster_id_params
		params.require(:id)
	end
	def monster_name_json_params
		params.require(:name)
	end
    def monster_params
		params.require(:monster).permit(:name,:url)
    end
	#Rails Cache
	def cache_data
		request_uri = 'https://www.padherder.com/api/monsters/'
		request_query = ''
		url = "#{request_uri}#{request_query}"
		#Rails.cache.clear
		Rails.cache.fetch("monster", expires_in: 12.hours) do
			JSON.parse(open(url).read)
		end

		request_uri = 'https://www.padherder.com/api/active_skills/'
		request_query = ''
		url = "#{request_uri}#{request_query}"

		Rails.cache.fetch("active_skills", expires_in: 12.hours) do
			JSON.parse(open(url).read)
		end

		request_uri = 'https://www.padherder.com/api/leader_skills/'
		request_query = ''
		url = "#{request_uri}#{request_query}"

		Rails.cache.fetch("leader_skills", expires_in: 12.hours) do
			JSON.parse(open(url).read)
		end

		request_uri = 'https://www.padherder.com/api/awakenings/'
		request_query = ''
		url = "#{request_uri}#{request_query}"

		Rails.cache.fetch("awakenings", expires_in: 12.hours) do
			JSON.parse(open(url).read)
		end
		
		request_uri = 'https://www.padherder.com/api/evolutions/'
		request_query = ''
		url = "#{request_uri}#{request_query}"

		Rails.cache.fetch("evolutions", expires_in: 12.hours) do
			JSON.parse(open(url).read)
		end
	end

	
#Unused
  def new
    @monster = Monster.new
    respond_with(@monster)
  end
  #Unused
  def edit
  end
  #Unused
  def update
    @monster.update(monster_params)
    respond_with(@monster)
  end	
  #Unused
  def destroy
    @monster.destroy
    respond_with(@monster)
  end
end
