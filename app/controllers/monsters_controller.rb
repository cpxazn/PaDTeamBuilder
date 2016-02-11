class MonstersController < ApplicationController
  require 'open-uri'
  before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :cache_monsters, only: [:index, :json, :show, :populate]

  respond_to :html

  def index
	@monsters = Rails.cache.fetch("monster").take(90)
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
	@subs = Array.new
	@subs_list = Monster.find(@monster["id"]).subs
	@subs_list = @subs_list.sort_by { | x | x[:score] }.reverse

	
	@subs_list.each do |s|
		@subs.push(idlookup(s[:id]))
	end

	
	@leaders = Array.new
	@leaders_list = Monster.find(@monster["id"]).leaders
	@leaders_list = @leaders_list.sort_by { | x | x[:score] }.reverse
	
	@leaders_list.each do |l|
		@leaders.push(idlookup(l[:id]))
	end
	
	#puts 'LEADERCOUNT:'+ @leaders.count.to_s
	
    respond_with(@monster)
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
			result.push(temp)
		end
	end
	
	render :json => result
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
