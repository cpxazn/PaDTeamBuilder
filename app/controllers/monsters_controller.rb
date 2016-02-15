class MonstersController < ApplicationController
  require 'open-uri'
  before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :cache_data, only: [:index, :json, :show, :populate]
  before_action :fetch_both, only: [:detail, :graph_since_json, :graph_monthly_json, :graph_count_json ]

  respond_to :html

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
	if @monsters == nil then raise ActionController::RoutingError.new('Not Found') end
	Rails.cache.fetch("monster")[starting + Rails.application.config.monster_list_max..ending + Rails.application.config.monster_list_max] == nil ? @more = 0 : @more = 1
    respond_with(@monsters)
  end

  def show
	@monster = fetch_monster_by_id_json(params[:id])
	if @monster != nil
		@subs = Array.new
		@leaders = Array.new
		
		#If this monster doesn't exist in our database
		if Monster.where(id: @monster["id"]).count == 0
					#Create using id and name from JSON
					@monster_db = Monster.create(id: @monster["id"], name: @monster["name"])
		else
					@monster_db = Monster.where(id: @monster["id"]).first
		end
		
		#Check to make sure this monster exists in the database
		if @monster_db != nil
			if @monster_db.name != @monster["name"] then 
				@monster_db.name = @monster["name"]
				@monster_db.save
			end
			@subs_list = Monster.find(@monster["id"]).subs
			@subs_list = @subs_list.sort_by { | x | x[:score] }.reverse
			@subs_list.each do |s|
				sub = idlookup(s[:id])
				if sub != nil
					@subs.push(sub)
				end
			end

			@leaders_list = Monster.find(@monster["id"]).leaders
			@leaders_list = @leaders_list.sort_by { | x | x[:score] }.reverse
			@leaders_list.each do |l|
				leader = idlookup(l[:id])
				if leader != nil
					@leaders.push(leader)
				end
			end
			
			@active_skill = fetch_active_skill_by_id_json(@monster["id"])
			@leader_skill = fetch_leader_skill_by_id_json(@monster["id"])
			@awakenings = fetch_awakenings_by_id_json(@monster["id"])
		else
			raise ActionController::RoutingError.new('Not Found')
		end
	else
		raise ActionController::RoutingError.new('Not Found')
	end
	
    respond_with(@monster)
  end

  def detail
	if @sub != nil and @leader != nil
		@score = @leader.score(@sub.id);
		@votes = @leader.vote_count(@sub.id);
		@score_all = @leader.fetch_score_all(@sub.id);
		@votes_all = @leader.fetch_vote_count_all(@sub.id);
		respond_to do |format|
			format.html
			format.js
		end
	end
  end
  
  def new
    @monster = Monster.new
    respond_with(@monster)
  end

  def edit
  end

  def create
    @monster = Monster.new(monster_params)
    @monster.save
    respond_with(@monster)
  end

  def update
    @monster.update(monster_params)
    respond_with(@monster)
  end	

  def destroy
    @monster.destroy
    respond_with(@monster)
  end
  
  def idlookup(id)
  	monster = id
	monsters = Rails.cache.fetch("monster")
	monsters.each do |m|
		if m["id"].to_s == monster.to_s
			return m
		end
	end
  end
  
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
  def graph_count_json
	data = Array.new
	data.push("Ratings")
	if @sub != nil and @leader != nil
		tmp2 = Array.new
		for i in (Rails.application.config.vote_display_max).downto(0)
			tmp = Array.new
			j = i + 1
			tmp.push(j.month.ago.strftime("%Y-%m-1"))
			tmp.push(@leader.fetch_vote_count_by_month(@sub.id, i))
			tmp2.push(tmp)
		end
		data.push(tmp2);
	end
	render :json => data
  end
  def graph_monthly_json
	data = Array.new
	data.push("Avg By Month")
	if @sub != nil and @leader != nil
		tmp2 = Array.new
		for i in (Rails.application.config.vote_display_max).downto(0)
			tmp = Array.new
			j = i + 1
			tmp.push(j.month.ago.strftime("%Y-%m-1"))
			tmp.push(@leader.fetch_score_by_month(@sub.id, i))
			tmp2.push(tmp)
		end
		data.push(tmp2);
	end
	render :json => data
  end
 
  def graph_since_json
	data = Array.new
	data.push("Avg Since");
	if @sub != nil and @leader != nil
		tmp2 = Array.new
		for i in (Rails.application.config.vote_display_max).downto(0)
			tmp = Array.new
			j = i + 1
			tmp.push(j.month.ago.strftime("%Y-%m-1"))
			tmp.push(@leader.fetch_score_ago_beg(@sub.id, i))
			tmp2.push(tmp)
		end
		data.push(tmp2);
	end
	render :json => data
  end

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
		@sub = fetch_monster_by_id(params["sub_id"])
		@sub_details = idlookup(@sub.id)
		@leader = fetch_monster_by_id(params["leader_id"])
		@leader_details = idlookup(@leader.id)
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
