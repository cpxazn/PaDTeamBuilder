class DungeonsController < ApplicationController
  before_action :set_dungeon, only: [:show, :edit, :update, :destroy]
  before_action :cache_data
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  
  # GET /dungeons
  # GET /dungeons.json
  def index
	dungeon_groups = DungeonGroup.order(:dungeon_type, :order)
	@dungeons = Array.new
	dungeon_groups.each do |dg|
		dg.dungeons.order(:dungeon_type, :order).each do |d|
			@dungeons.push(d)
		end
	end
  end

  # GET /dungeons/1
  # GET /dungeons/1.json
  def show
  end

  # GET /dungeons/new
  def new
    @dungeon = Dungeon.new
  end

  # GET /dungeons/1/edit
  def edit
  end

  # POST /dungeons
  # POST /dungeons.json
  def create
    @dungeon = Dungeon.new(dungeon_params)

    respond_to do |format|
      if @dungeon.save
        format.html { redirect_to @dungeon, notice: 'Dungeon was successfully created.' }
        format.json { render :show, status: :created, location: @dungeon }
      else
        format.html { render :new }
        format.json { render json: @dungeon.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def cache_data
	update = 0
	Rails.cache.fetch("normal_dungeon", expires_in: 24.hours) do
		update = 1
		cache_dungeons("normal","src")
	end
	if update == 1 then update_dungeons("normal_dungeon") end
	
	update = 0
	Rails.cache.fetch("special_dungeon", expires_in: 24.hours) do
		update = 1
		cache_dungeons("special","data-original")
	end
	if update == 1 then update_dungeons("special_dungeon") end
	
	update = 0
	Rails.cache.fetch("technical_dungeon", expires_in: 24.hours) do
		update = 1
		cache_dungeons("technical","data-original")
	end
	if update == 1 then update_dungeons("technical_dungeon") end
	
	update = 0
	Rails.cache.fetch("multiplayer_dungeon", expires_in: 24.hours) do
		update = 1
		cache_dungeons("multiplayer","data-original")
	end
	if update == 1 then update_dungeons("multiplayer_dungeon") end
	
  end
  
  def update_dungeons(t)
	dungeons = Rails.cache.fetch(t)
	dungeon_id_list = Array.new
  	dungeons.each do |k,v|
		if DungeonGroup.where(name: k, dungeon_type: t).count == 0
			dg = DungeonGroup.create(name: k, dungeon_type: t.to_s, order: v["order"]) 
		else
			dg = DungeonGroup.where(name: k, dungeon_type: t).first
			if dg.order != v["order"] then dg.update(order: v["order"]) end
			#if dg.dungeon_type != t then dg.update(dungeon_type: t) end
		end
		#rearrange = false
		v["dungeons"].each do |id, details|
			dungeon_id_list.push(id.to_i)
			if details["stamina"] == "--" then details["stamina"] = nil end
			if details["floors"] == "--" then details["floors"] = nil end
			if details["coins"] == "--" then details["coins"] = nil end
			if details["exp"] == "--" then details["exp"] = nil end
			if Dungeon.where(id: id).count == 0
				Dungeon.create(id: id.to_i, dungeon_group_id: dg.id, name: details["name"], stamina: details["stamina"], floors: details["floors"], coins: details["coins"], exp: details["exp"], img: details["img"], dungeon_type: t, order: details["order"])
			else
				d = Dungeon.find(id)
				if d.dungeon_group_id != dg.id then d.update(dungeon_group_id: dg.id) end
				if d.name != details["name"] then d.update(name: details["name"]) end
				if d.stamina != details["stamina"] then d.update(stamina: details["stamina"]) end
				if d.floors != details["floors"] then d.update(floors: details["floors"]) end
				if d.coins != details["coins"] then d.update(coins: details["coins"]) end
				if d.exp != details["exp"] then d.update(exp: details["exp"]) end
				if d.img != details["img"] then d.update(img: details["img"]) end
				if d.dungeon_type != t then d.update(dungeon_type: t) end
				if d.order != details["order"] then d.update(order: details["order"]) end
			end
		end
	end
	Dungeon.where(dungeon_type: t).each do |d|
		if not dungeon_id_list.include? d.id
			if not d.name.include? "Removed?"
				d.update(name: d.name + ' (Removed?)')
			end
		end
	end
  end
  def get_normal_dungeons
	dungeons_hash = Rails.cache.fetch("normal_dungeon")
	render :json => dungeons_hash
  end
  def get_special_dungeons
	dungeons_hash = Rails.cache.fetch("special_dungeon")
	render :json => dungeons_hash
  end
  def get_technical_dungeons
	dungeons_hash = Rails.cache.fetch("technical_dungeon")
	render :json => dungeons_hash
  end
  def get_multiplayer_dungeons
	dungeons_hash = Rails.cache.fetch("multiplayer_dungeon")
	render :json => dungeons_hash
  end
  def cache_dungeons(dungeon_type, attr)
  	dungeons_hash = Hash.new
	dungeons_html = open('http://www.puzzledragonx.com/en/' + dungeon_type + '-dungeons.asp').read
	dungeons_html = dungeons_html.split('<table id="tabledrop">')[1]
	dungeons_html = dungeons_html.split('<tr><td colspan="6" style="padding: 0px;">')[0]
	dungeons_html = dungeons_html.gsub(/(?:\n\r?|\r\n?)/, '')
	dungeons_html = dungeons_html.gsub('</td></td></tr><tr><td colspan=','</td></td></tr></dungeon_group><tr><td colspan=')
	dungeons_html = dungeons_html.gsub('<tr><td colspan="10" style="padding: 0px;">','<dungeon_group><tr><td colspan="10" style="padding: 0px;">')
	dungeons_html = dungeons_html.gsub('</td> </tr>','</td></dungeon></tr>')
	dungeons_html = dungeons_html.gsub('<td class="mavatar">','<dungeon><td class="mavatar">')
	dungeons_html = Nokogiri::HTML(dungeons_html)
	dungeon_groups = dungeons_html.css('dungeon_group')
	dungeon_group_order = 0
	dungeon_groups.each do |dg|
		dungeon_group_order = dungeon_group_order + 1
		dungeon_group_name = dg.at_css('h2').content.to_s
		tmp = Hash.new
		dungeons = dg.css('dungeon')
		dungeon_order = 0
		dungeons.each do |d|
			dungeon_order = dungeon_order + 1
			dungeon_name = d.at_css('a').content
			dungeon_details = d.css('td')
			dungeon_img = d.at_css('img').attr(attr).to_s
			dungeon_id = d.at_css('a').attribute('href').to_s.split('=')[1]
			if dungeon_details.length == 8
				dungeon_stamina = dungeon_details[2].content.to_s
				dungeon_floors = dungeon_details[3].content.to_s
				dungeon_coins = dungeon_details[4].content.to_s
				dungeon_exp = dungeon_details[5].content.to_s
				tmp[dungeon_id.to_s] = {"name" => dungeon_name, "stamina" => dungeon_stamina, "floors" => dungeon_floors, "coins" => dungeon_coins, "exp" => dungeon_exp, "img" => dungeon_img, "order"=> dungeon_order}
			end
		end
		dungeons_hash[dungeon_group_name] = {"order" => dungeon_group_order, "dungeons" => tmp}
	end
	return dungeons_hash
  end


  # PATCH/PUT /dungeons/1
  # PATCH/PUT /dungeons/1.json
  def update
    respond_to do |format|
      if @dungeon.update(dungeon_params)
        format.html { redirect_to @dungeon, notice: 'Dungeon was successfully updated.' }
        format.json { render :show, status: :ok, location: @dungeon }
      else
        format.html { render :edit }
        format.json { render json: @dungeon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dungeons/1
  # DELETE /dungeons/1.json
  def destroy
    @dungeon.destroy
    respond_to do |format|
      format.html { redirect_to dungeons_url, notice: 'Dungeon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dungeon
      @dungeon = Dungeon.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dungeon_params
      params.require(:dungeon).permit(:dungeon_group_id, :name, :stamina, :floors, :coin, :exp, :img)
    end
end
