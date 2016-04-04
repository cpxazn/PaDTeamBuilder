class MonsterLinksController < ApplicationController
	before_action :set_monster_link, only: [:edit, :update, :destroy]
	before_action :authenticate_user!, only: [:new, :create, :edit, :destroy]
	require 'open-uri'
	require 'open_uri_redirections'
	
	def new
		@monster_link = MonsterLink.new
		@monster_id = params[:monster_id]
		if @monster_id == nil then redirect_to root_path end
		@url_readonly = false
	end
	def edit
		if current_user != @monster_link.user
			redirect_to @monster_link.monster, alert: 'Error: This link does not belong to you'
		end
		@monster_id = @monster_link.monster.id
		@url_readonly = true
	end
	def update
		begin
			title = Nokogiri::HTML(open(@monster_link.url, :allow_redirections => :all)).at_css('title').content.strip
		  
			rescue Errno::ENOENT
				if not @monster_link.url.include? "http"
					@monster_link.url = "http://" + @monster_link.url
					retry
				else
					flash.now[:alert] = "Error: Could not process URL"
					render :new
					return
				end
			rescue
				flash.now[:alert] = "Error: Could not process URL"
				render :new
				return

		end
		if title.include? "| Puzzle" then title = title.split("| Puzzle")[0] end
		if title.include? ": PuzzleAndDragons" then title = title.split(": PuzzleAndDragons")[0] end
		@monster_link.title = title
		
		if @monster_link.update(monster_link_params)
			redirect_to @monster_link.monster, notice: 'Link was successfully updated.'
		end
    end
	def create
		@monster_link = MonsterLink.new(monster_link_params)
		@monster_id = @monster_link.monster_id
		@monster_link.user_id = current_user.id
		
		if not @monster_link.url.include? 'reddit.com/r/' and not @monster_link.url.include? 'puzzleanddragonsforum.com'
			flash.now[:alert] = "Error: Please only enter URLs from reddit and puzzleanddragonsforum"
			render :new
		else	
			begin
				title = Nokogiri::HTML(open(@monster_link.url, :allow_redirections => :all)).at_css('title').content.strip
			  
				rescue Errno::ENOENT
					if not @monster_link.url.include? "http"
						@monster_link.url = "http://" + @monster_link.url
						retry
					else
						flash.now[:alert] = "Error: Could not process URL. Either issue with URL or try again later."
						render :new
						return
					end
				rescue
					flash.now[:alert] = "Error: Could not process URL. Either issue with URL or try again later."
					render :new
					return

			end
			if title.include? "| Puzzle" then title = title.split("| Puzzle")[0] end
			if title.include? ": PuzzleAndDragons" then title = title.split(": PuzzleAndDragons")[0] end
			@monster_link.title = title
			
			if @monster_link.save
				flash.now[:notice] = "Link Submitted"
				redirect_to @monster_link.monster, notice: flash[:notice], alert: flash[:alert]
			else
				flash.now[:alert] = "Error: Unable to submit link"
				render :new
			end
		end
	end
	
	def destroy	
		if current_user == @monster_link.user
			@monster_link.destroy
			redirect_to @monster_link.monster, notice: 'Link successfully deleted.'
		else
			redirect_to @monster_link.monster, alert: 'Error: This link does not belong to you!'
		end
	end
	
    def set_monster_link
		@monster_link = MonsterLink.find(params[:id])
    end
	def monster_link_params
		params.require(:monster_link).permit(:url,:link_type,:version_id,:monster_id)
	end
end
