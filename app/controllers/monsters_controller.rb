class MonstersController < ApplicationController
  require 'open-uri'
  before_action :set_monster, only: [:edit, :update, :destroy]
  before_action :cache_monsters, only: [:index, :json, :show]

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
  
  def typeahead_json
	monster = monster_json_params
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
	
	def monster_json_params
	  params.require(:name)
	end

    def monster_params
      params.require(:monster).permit(:name)
    end
end
