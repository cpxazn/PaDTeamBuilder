class MonstersController < ApplicationController
  require 'open-uri'
  #before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :cache_data, only: [:index, :json, :show, :populate, :details]
  before_action :fetch_both, only: [:detail, :graph_since_json, :graph_monthly_json, :graph_count_json, :graph_weight_json, :graph_json ]
  before_action :authenticate_user!, only: [:add_tag, :add_pair_tag]

  respond_to :html
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
					leader.tag_list_on(context).add(new) 
				end
			end
			leader.save
			leader.reload
			#tags = @leader.tag_list
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
					monster.tag_list.add(new) 
				end
			end
			monster.save
			monster.reload
			#tags = @monster.tag_list
		end
		respond_to do |format|
			format.js
		end
  end 
  #Uses @page to keep track of page number. Formulas are used to determine which monsters to display.
  #@monsters is the list of monsters to be displayed
  def index
	@page = params[:page].to_i
	if @page.is_a? Numeric and @page != nil and @page > 0
		starting = (@page - 1) * Rails.application.config.monster_list_max
	else
		starting = 0
		@page = 0
	end
	ending = starting + Rails.application.config.monster_list_max - 1
	@monsters = Rails.cache.fetch("monster")[starting..ending]
	if @monsters == nil then render_404; return; end
	Rails.cache.fetch("monster")[starting + Rails.application.config.monster_list_max..ending + Rails.application.config.monster_list_max] == nil ? @more = 0 : @more = 1
    respond_with(@monsters)
  end
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
  #Shows a particular monster from JSON. Input parameter is params[:id]
  def show
	@monster = fetch_monster_by_id_json(params[:id])
	
	#Make sure monster was fetched
	if @monster != nil
		@monster_db = fetch_monster_by_id(@monster["id"])
		@subs = Array.new
		@leaders = Array.new
		
		#Check to make sure this monster exists in the database
		if @monster_db != nil
			#Update monster name if it has changed
			if @monster_db.name != @monster["name"] then 
				@monster_db.name = @monster["name"]
				@monster_db.save
			end
			#Get suggested subs
			@subs_list = Monster.find(@monster["id"]).subs
			@subs_list = @subs_list.sort_by { | x | x[:score] }.reverse
			@subs_list.each do |s|
				sub = fetch_monster_by_id_json(s[:id])
				if sub != nil
					@subs.push(sub)
				end
			end

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
  #Returns json data
  def idlookup_json
  	monster = monster_id_json_params
	monsters = Rails.cache.fetch("monster")
	monsters.each do |m|
		if m["id"].to_s == monster.to_s
			render :json => m
			break
		end
	end
  end
  #Gets monster parameters for typeahead
  def typeahead_json
	monster = monster_name_json_params
	monsters = Rails.cache.fetch("monster")
	result = Array.new
	monsters.each do |m|
		if m["name"].upcase.include? monster.upcase
			temp = Hash.new
			temp["name"] = m["name"]
			temp["id"] = m["id"]
			temp["img_url"] = m["image60_href"]
			result.push(temp)
		end
	end
	
	render :json => result
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
  #Not used
  def populate
		monsters = Rails.cache.fetch("monster")
		monsters.each do |m|
			monster = Monster.where(id: m["id"]).first_or_initialize
			monster.name = m["name"]
			monster.save
		end
		#@monster = Monster.find(params[:id])
		redirect_to monsters_path
  end
  #Caching
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
end
