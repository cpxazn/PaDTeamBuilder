class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :index]
  
  respond_to :html


  
  def index
  	@page = params[:page].to_i
	if @page.is_a? Numeric and @page != nil and @page > 0
		starting = (@page - 1) * Rails.application.config.vote_list_max
	else
		starting = 0
		@page = 0
	end
	ending = starting + Rails.application.config.vote_list_max - 1
	@count = current_user.votes.count
    @votes = current_user.votes.order(created_at: :desc)[starting..ending]
	#if @votes == nil then render_404; return; end
	current_user.votes.limit(1000)[starting + Rails.application.config.vote_list_max..ending + Rails.application.config.vote_list_max] == nil ? @more = 0 : @more = 1
    #respond_with(@votes)
  end
  
  def statistics
	@page = params[:page].to_i
	if @page.is_a? Numeric and @page != nil and @page > 0
		starting = (@page - 1) * Rails.application.config.vote_list_max
	else
		starting = 0
		@page = 0
	end
	ending = starting + Rails.application.config.vote_list_max - 1
    @votes = Vote.order(created_at: :desc).limit(1000)[starting..ending]
	#if @votes == nil then render_404; return; end
	Vote.all[starting + Rails.application.config.vote_list_max..ending + Rails.application.config.vote_list_max] == nil ? @more = 0 : @more = 1
    #respond_with(@votes)
  end

  def show

  end

  def new
    @vote = Vote.new
    respond_with(@vote)
  end

  def edit
  end
  

  def create

	monster_id = params[:monster_id]
	monster_name = params[:monster_name]
	monster = fetch_monster_by_one(monster_id, monster_name)
	current = params[:current_id]
	option = params[:commit].downcase
	rating = params[:rating]

	if monster == nil then monster = create_monster(monster_id, monster_name) end
	
	if is_number?(rating) and rating.to_i <= Rails.application.config.vote_rating_max and rating.to_i >= 0
		
		if monster != nil
			rating = rating.to_i
			
			if (option =~ /^sub$/)
				monster_id2 = monster.id
				monster_id1 = current.to_i
				type = "ls"
			elsif (option =~ /^leader\/leader$/)
				type = "ll"
				if current.to_i <= monster.id.to_i 
					monster_id1 = current.to_i
					monster_id2 = monster.id.to_i	
				else
					monster_id1 = monster.id.to_i
					monster_id2 = current.to_i
				end
			elsif (option =~ /^leader$/)
				monster_id2 = current.to_i
				monster_id1 = monster.id
				type = "ls"
			else
				redirect_to monster_path(current)
				return
			end
			
			if Monster.where(id: monster_id1).count == 1 and Monster.where(id: monster_id2).count == 1
				if user_voted_default_month(monster_id1, monster_id2, type)
					vote = fetch_user_vote_by_default_month(monster_id1, monster_id2, type)
					if rating > 0
						if vote.update(score: rating.to_i)
							flash.now[:notice] = 'Vote Updated'
						else
							flash.now[:alert] = 'Error: Could not save vote!'
						end
					else
						vote.destroy
						flash.now[:notice] = 'Vote Removed'
					end
				else
					if rating > 0
						case type
							when "ls"
								vote = Vote.new(score:rating.to_i,leader_id: monster_id1, sub_id: monster_id2, user_id: current_user.id)
							when "ll"
								vote = VoteLl.new(score:rating.to_i,leaders: [monster_id1, monster_id2], user_id: current_user.id)
						end
						if vote.save
							flash.now[:notice] = 'Vote Submitted.' + option
						else
							flash.now[:alert] = 'Error: Could not save vote!'
						end
					else
						flash.now[:alert] = 'Error: Could not save vote!'
					end
				end
			else
				flash.now[:alert] = 'Error: ' + monster_id1.to_s + ' is not a valid monster id'
			end
		else
			flash.now[:alert] = 'Error: Invalid monster name'
		end
	else
		flash.now[:alert] = 'Error: Invalid parameters'
	end
	redirect_to monster_path(current), notice: flash[:notice], alert: flash[:alert]
    #respond_with(@vote)
  end

  def update
    @vote.update(vote_params)
    respond_with(@vote)
  end

  def destroy
    @vote.destroy
    respond_with(@vote)
  end

  private
    def set_vote
      @vote = Vote.find(params[:id])
    end

    def vote_params
      params.require(:vote).permit(:score)
    end
end
