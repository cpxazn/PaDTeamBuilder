class MonstersController < ApplicationController
  require 'open-uri'
  require 'open_uri_redirections'
  before_action :cache_data
  #before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :fetch_both, only: [:detail, :graph_since_json, :graph_monthly_json, :graph_count_json, :graph_weight_json, :graph_json ]
  before_action :authenticate_user!, only: [:add_tag, :add_pair_tag, :tag_update]
  respond_to :html
  
	
  def image_proxy
	remote_url = Rails.application.config.img_path_monsters + "#{request.path}"
	local_url = "public#{request.path}"
  
	if not File.exist? local_url
		IO.copy_stream(open(remote_url, :allow_redirections => :safe), local_url)
	end
 
	send_file local_url, type: 'image/png', disposition: 'inline'
  end
	
  def search
	@tags = ActsAsTaggableOn::Tag.order(taggings_count: :desc)
	@selected = params[:tags]
	if @selected != nil and @selected.size > 0
		monsters = Monster.tagged_with(@selected, :on => :tags)
		@monsters = fetch_monster_json_by_array(monsters)
		if @monsters != nil then @monsters = @monsters.sort_by { |hash| hash['element'].to_i } end 
	end
  end
  
  def index
	@latestVotes = Vote.order(created_at: :desc).limit(5)
	@topMonsters = Monster.top
	@topUsers = User.top
	@latestComments = Comment.latest
  end
  #Shows a particular monster from JSON. Input parameter is params[:id]
  def show
	@monster = fetch_monster_by_id_json(params[:id])

	#Make sure monster was fetched
	if @monster != nil
		@monster_db = fetch_monster_by_id(@monster["id"])
		
		#Check to make sure this monster exists in the database
		if @monster_db != nil			
			#Update monster name if it has changed
			if @monster_db.name != @monster["name"] then 
				@monster_db.name = @monster["name"]
				@monster_db.save
			end
			
			@subs = Array.new
			#Get suggested subs
			@subs_list = Monster.find(@monster["id"]).subs
			@subs_list = @subs_list.sort_by { | x | x[:score] }.reverse
			@subs_list.each do |s|
				sub = fetch_monster_by_id_json(s[:id])
				if sub != nil
					@subs.push(sub)
				end
			end
			
			@leaders = Array.new
			#Get suggested leaders
			@leaders_list = Monster.find(@monster["id"]).leaders
			@leaders_list = @leaders_list.sort_by { | x | x[:score] }.reverse
			@leaders_list.each do |l|
				leader = fetch_monster_by_id_json(l[:id])
				if leader != nil
					@leaders.push(leader)
				end
			end
			
			#Get other details
			@active_skill = fetch_active_skill_by_id_json(@monster["id"])
			@leader_skill = fetch_leader_skill_by_id_json(@monster["id"])
			@awakenings = fetch_awakenings_by_id_json(@monster["id"])
			@related = @monster_db.get_all_evo
		else
			render_404; return;
		end
	else
		render_404; return;
	end
	
    respond_with(@monster)
  end
  #Gets rating details, passes to modale or actual view
  def detail
	if @sub != nil and @leader != nil
		@score = @leader.score(@sub.id);
		@votes = @leader.vote_count(@sub.id);
		@score_all = @leader.fetch_score_all(@sub.id);
		@votes_all = @leader.fetch_vote_count_all(@sub.id);
		@comments = Comment.sorted(@leader.id, @sub.id)
		respond_to do |format|
			format.html
			format.js
		end
	end
  end
 
  def add_pair_tag
	new_tags = params[:tags]
	leader_id = params[:monster_id]
	sub_id = params[:sub_id]
	sub = fetch_monster_by_id(sub_id)
	leader = fetch_monster_by_id(leader_id)
	context = "sub_" + sub_id.to_s
	if new_tags == nil then new_tags = [] end
	if leader != nil and sub != nil
		old_tags = leader.tag_list_on(context).dup
		if old_tags == nil then old_tags = [] end
		old_tags.each do |old|
			found = 0
			new_tags.each do |new|
				if old == new then 
					found = 1 
				end
			end
			if found == 0 then 
				leader.tag_list_on(context).remove(old) 
			end
		end
		old_tags = leader.tag_list_on(context).dup
		new_tags.each do |new|
			found = 0
			old_tags.each do |old|
				if new == old then found = 1 end
			end
			if found == 0 then 
				if new.length <= Rails.application.config.tag_max_length 
					leader.tag_list_on(context).add(new) 
				else
					flash.now[:alert] = 'Error: One or more tags could not be saved due to length limitation: ' + Rails.application.config.tag_max_length.to_s 
				end
			end
		end
		leader.save
		leader.reload
		@tags = leader.tag_list_on(context)
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
  #Graphs
  def graph_json
	if params["graph"] == nil
		render_404; return;
	else
		@graph = params["graph"]
	end
	data = Array.new
	puts "graph: " + @graph
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
					tmp.push(@leader.fetch_vote_count_by_month(@sub.id, i))
				when "monthly"
					tmp.push(@leader.fetch_score_by_month(@sub.id, i))
				when "since"
					tmp.push(@leader.fetch_score_ago_beg(@sub.id, i))
				when "weighted"
					tmpData = @leader.fetch_weighted_avg(@sub.id, i)
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
    def fetch_both
		if params["sub_id"] == nil or params["leader_id"] == nil then render_404; return; end
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
	def monster_id_json_params
		params.require(:id)
	end
	def monster_name_json_params
		params.require(:name)
	end
    def monster_params
		params.require(:monster).permit(:name)
    end
	#Rails Cache
	def cache_data
		request_uri = 'https://www.padherder.com/api/monsters/'
		request_query = ''
		url = "#{request_uri}#{request_query}"

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
