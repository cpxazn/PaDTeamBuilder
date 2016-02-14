class MonstersController < ApplicationController
  require 'open-uri'
  before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :cache_monsters, only: [:index, :json, :show, :populate]
  before_action :fetch_both, only: [:detail, :graph_since_json, :graph_monthly_json, :graph_count_json ]

  respond_to :html

  def index
	@page = params[:page].to_i
	if @page.is_a? Numeric and @page != nil and @page > 0
		starting = (@page - 1) * 90
	else
		starting = 0
		@page = 0
	end
	ending = starting + 89
	@monsters = Rails.cache.fetch("monster")[starting..ending]
    respond_with(@monsters)
  end

  def show
	monsters = Rails.cache.fetch("monster")
	monsters.each do |m|
		if m["id"].to_s == params[:id].to_s
			@monster = m
			break
		end
	end
	if @monster != nil
		@subs = Array.new
		@leaders = Array.new
		
		if Monster.where(id: @monster["id"]).count > 0
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
		end
	end
	
    respond_with(@monster)
  end

  def detail
	if @sub != nil and @leader != nil
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
  def cache_monsters
	request_uri = 'https://www.padherder.com/api/monsters/'
  	#request_uri = 'C:\Sites\PadTeamBuilder\public\monsters.json'
	request_query = ''
	url = "#{request_uri}#{request_query}"

	Rails.cache.fetch("monster", expires_in: 12.hours) do
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
