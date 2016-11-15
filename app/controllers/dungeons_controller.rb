class DungeonsController < ApplicationController
  before_action :set_dungeon, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  before_action :cache_dungeon_data
  
  # GET /dungeons
  # GET /dungeons.json
  def index
	@title = "Dungeons"
	
	@normal = DungeonGroup.where(dungeon_type: "normal_dungeon").order(:id)
	@technical = DungeonGroup.where(dungeon_type: "technical_dungeon").order(:id)
	@special = DungeonGroup.where(dungeon_type: "special_dungeon").order(:id)
	@multiplayer = DungeonGroup.where(dungeon_type: "multiplayer_dungeon").order(:id)
	@all_dungeons = {"normal" => @normal, "technical" => @technical, "special" => @special, "multiplayer" => @multiplayer}
	#@dungeons = Array.new
	#@dungeon_groups.each do |dg|
	#	dg.dungeons.order(:dungeon_type, :order).each do |d|
	#		@dungeons.push(d)
	#	end
	#end
  end

  # GET /dungeons/1
  # GET /dungeons/1.json
  def show
	@filter = params[:filter]
  
	@title = @dungeon.id.to_s + " | Dungeon"
    @dungeon_html = cache_dungeon_html(@dungeon)
	@dungeon_threats = cache_dungeon_threats(@dungeon_html, @dungeon)
	@dungeon_restrictions = cache_dungeon_restrictions(@dungeon_html, @dungeon)
	
	@threats = Array.new
	
	@dungeon_threats.each do |key, value|
		filter_out = Array.new
		value.each_with_index do |val, index|
			@threats.push val["label"]
			if @filter != nil and not @filter.include? val["label"] then filter_out.push(val["label"]) end
		end
		value.delete_if { |a| filter_out.include? a["label"] }
	end
	@threats.uniq!
	

	
  end
  def cache_dungeon_restrictions(dungeon_html, dungeon)
  	#Rails.cache.clear
	restrictions = Rails.cache.fetch("dungeon_restrictions_" + dungeon.id.to_s, expires_in: 10.minutes) do
		dungeon_html = Nokogiri::HTML(dungeon_html)
		restrictions = dungeon_html.at_css('div.restriction-container span')
		#puts restrictions
		if restrictions != nil
			restrictions = restrictions.content
			if restrictions.include? "ATTENTION:" then restrictions = restrictions.split('ATTENTION:')[1].strip end
		else
			restrictions = ""
		end
		restrictions
	end
	return restrictions
  end
  def cache_dungeon_html(dungeon)
	#Rails.cache.clear
	dungeon_info = Rails.cache.fetch("dungeon_info_" + dungeon.id.to_s, expires_in: 10.minutes) do
		dungeon_html = open('http://www.puzzledragonx.com/en/mission.asp?m=' + dungeon.id.to_s).read
		restriction  = dungeon_html[/<div.*?restriction-container.*?<\/div><\/div>/]
		dungeon_html = dungeon_html.split('<table id="tabledrop">')[1]
		dungeon_html = dungeon_html.split('<div style="padding-left: 48px; float: right;">Loot</div></th></tr>')[1]
		dungeon_html = dungeon_html.split('</table>')[0]
		dungeon_html = dungeon_html.gsub(/(?:\n\r?|\r\n?)/, '')
		dungeon_html = dungeon_html.gsub(/(?!<tr><td>\d.*?<td class="enemy">)<tr>.*?floor.*?<\/tr>/,'')
		dungeon_html = dungeon_html.gsub('<tr><td>','<tr><monster><td>')
		dungeon_html = dungeon_html.gsub('</td></tr>','</td></monster></tr>')
		dungeon_html = dungeon_html.gsub('<br>','|')
		dungeon_html = dungeon_html.gsub(/(<span class="skillexpand">.*?trigger.*?info.*?<\/div>)/,'<skills>\1</skills>')
		dungeon_html = dungeon_html.gsub('Passive.', 'Passive|')
		dungeon_html = dungeon_html.gsub('Pre-emptive Strike.', 'Pre-emptive|')
		if restriction != nil then dungeon_html = restriction + dungeon_html end
		dungeon_html
	end
	return dungeon_info
  end
  def cache_dungeon_threats(dungeon_html, dungeon)
	#Rails.cache.clear
	passive = Array.new
	preemp = Array.new
	skill = Array.new
		
	dungeon_threats = Rails.cache.fetch("dungeon_threats_" + dungeon.id.to_s, expires_in: 1.seconds) do
		dungeon_html = Nokogiri::HTML(dungeon_html)
		monsters = dungeon_html.css('monster')
		dungeon_info = Array.new
		monsters.each do |m|
			id = m.at_css('td.enemy a').attr('href').split('=')[1].to_i
			name = m.at_css('td.enemy > a > img').attr('title').gsub(/No.\d+ /,'')
			floor =  m.css('td')[0].content.to_i
			stats = m.css('span.nc')
			attack = stats[0].content
			defense = stats[1].content
			hp = stats[2].content
			skills = Array.new
			mskills = m.css('skills')
			mskills.each do |s|
				#puts s
				#puts "------"
				details = s.at_css('span.bossAtk')
				if details != nil then details = "(" + details.content + ")" else details = "" end
				
				content = s.at_css('div[id$=info]').content
				if (content[0..10] == "Pre-emptive" or content[0..6] == "Passive") and content.split('|').size == 2
					content = "|" + content
				elsif content.split('|').size == 2
					content.gsub!('|','|Skill|')
				elsif content.split('|').size == 1
					content = '|Skill|' + content
				end
				
				condition = content.split('|')[0].strip
				type = content.split('|')[1].strip
				effect = content.split('|')[2].strip + details
				skills.push({"condition" => condition, "type" => type, "effect" => effect})
			end

			monster = {"floor" => floor, "id" => id, "name" => name, "skills" => skills, "attack" => attack, "defense" => defense, "hp" => hp}
			dungeon_info.push(monster)
		end

		threats = {
			"Absorb Damage Over" => "absorbs single hit damage over",
			"Absorb Combo Less" => "damage you cause for combos",
			"Absorbs Dark damage" => "absorbs 100% dark damage",
			"Absorbs Light damage" => "absorbs 100% light damage",
			"Absorbs Water damage" => "absorbs 100% water damage",
			"Absorbs Fire damage" => "absorbs 100% fire damage",
			"Absorbs Wood damage" => "absorbs 100% wood damage",
			"Bind" => "bind",
			"Skill Bind" => "disable active skills",
			"Disable Awoken Skills" => "Disable awoken skills",
			"Increase Cooldown" => "increases cooldown of active skills",
			"Jammer Orb" => "to jammer orb",
			"Poison Board" => "spawn 42 Poison orbs",
			"Skyfall" => "increases skyfall chance",
			"Resolve" => "leave it with 1 hp",
			"Hide Orbs" => "hide all orbs on the board",
			"Recover Player HP" => "recovers player 100%",
			"Immunity" => "immunity",
			"Reduce Orb Movement" => "orb movement timer",
			"Temporary Damage Reduction" => "damage reduction for",
			"Passive Damage Reduction" => "damage reduction.",
			"Leader Swap" => "random sub as player's leader",
			"99% Gravity" => "player -99%",
			"Instant KO" => "player -100%",
			"Locked Orbs" => "into locked orbs"
		}

		dungeon_info.each do |m|
			m["skills"].each do |s|
				threats.each do |key, value|
					if s["effect"].downcase.include?(value.downcase)
						case s["type"].downcase
							when "passive"
								passive.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => s["condition"], "effect" => s["effect"], "label" => key})
							when "pre-emptive"
								preemp.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => s["condition"], "effect" => s["effect"], "label" => key})
							when "skill"
								#if s["effect"].downcase.include?("deal")
								#	damage = "(" + ((s["effect"][/[\d]+?%/].gsub('%','').to_i / 100.0) * m["attack"].to_i).to_i.to_s + ")"
								#else
								#	damage = ""
								#end
								skill.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => s["condition"], "effect" => s["effect"], "label" => key})
						end
					end
				end
				if s["type"].downcase == "pre-emptive" and s["effect"].downcase.include?("deal")
					#damage = "(" + ((s["effect"][/[\d]+?%/].gsub('%','').to_i / 100.0) * m["attack"].to_i).to_i.to_s + ")"
					preemp.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => s["condition"], "effect" => s["effect"], "label" => "Deal Damage"})
				end
			end
			if is_number?(m["defense"]) and m["defense"].to_i > 200000
				passive.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => "", "effect" => m["defense"].to_s + " DEF", "label" => "High Defense (200k+)"})
			end
			if is_number?(m["hp"]) and m["hp"].to_i > 8000000
				passive.push({"floor" => m["floor"], "id"=> m["id"], "name" => m["name"], "condition" => "", "effect" => m["hp"].to_s + " HP", "label" => "High HP (8 Mill+)"})
			end
		end
		passive.sort_by! { |key, value| key["floor"]}
		preemp.sort_by! { |key, value| key["floor"]}
		skill.sort_by! { |key, value| key["floor"]}
		{"passive" => passive, "preemp" => preemp, "skill" => skill}
	end
	return dungeon_threats
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
  
  def cache_dungeon_data
    #Rails.cache.clear
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
			dg = DungeonGroup.create(name: k, dungeon_type: t.to_s) 
		else
			dg = DungeonGroup.where(name: k, dungeon_type: t.to_s).first
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
  def get_dungeon_details
  
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
