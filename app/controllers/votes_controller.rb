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
	if @votes == nil then raise ActionController::RoutingError.new('Not Found') end
	current_user.votes[starting + Rails.application.config.vote_list_max..ending + Rails.application.config.vote_list_max] == nil ? @more = 0 : @more = 1
    respond_with(@votes)
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
	puts params.inspect
	monster_id = params[:monster_id]
	monster_name = params[:monster_name]
	monster = fetch_monster_by_one(monster_id, monster_name)
	current = params[:current_id]
	option = params[:commit]
	rating = params[:rating]
	puts 'option:' + option
	if rating.to_s 	=~ /[1-5]/
		if monster != nil
			if (option =~ /^Sub/)
				sub_id = monster.id
				leader_id = current
				puts option
				puts 'leaderid:' + leader_id.to_s
				puts 'subid:' + sub_id.to_s
			elsif (option =~ /^Leader/)
				sub_id = current
				leader_id = monster.id
				puts option
				puts 'leaderid:' + leader_id.to_s
				puts 'subid:' + sub_id.to_s
			else
				redirect_to monster_path(current)
			end
			
			if Monster.where(id: leader_id).count == 1 and Monster.where(id: sub_id).count == 1
				if user_voted_default_month(leader_id, sub_id)
					vote = fetch_user_vote_by_default_month(leader_id, sub_id)
					if vote.update(score: rating.to_i)
						flash.now[:notice] = 'Vote Updated'
					else
						flash.now[:alert] = 'Error: Could not save vote!'
					end
				else
					vote = Vote.new(score:rating.to_i,leader_id: leader_id, sub_id: sub_id, user_id: current_user.id)
					if vote.save
						flash.now[:notice] = 'Vote Submitted'
					else
						flash.now[:alert] = 'Error: Could not save vote!'
					end
				end
			else
				flash.now[:alert] = 'Error: ' + leader_id.to_s + ' is not a valid monster id'
			end
		else
			flash.now[:alert] = 'Error: ' + params[:monster_name] + ' is not a valid monster name'
		end
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
