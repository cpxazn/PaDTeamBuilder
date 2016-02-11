class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create]
  
  respond_to :html

  def index
    @votes = Vote.all
    respond_with(@votes)
  end

  def show
    respond_with(@vote)
  end

  def new
    @vote = Vote.new
    respond_with(@vote)
  end

  def edit
  end

  def create
    puts params.inspect
	monster = Monster.where(name: params[:monster_name])
	current = params[:current_id]
	option = params[:commit]
	if monster.all.count == 1
		if option == "Sub"
			sub_id = monster.first.id
			leader_id = current
		elsif option == "Leader"
			sub_id = current
			leader_id = monster.first.id
		end
		
		if Monster.where(id: leader_id).count == 1
			vote = Vote.new(score:1,leader_id: leader_id, sub_id: sub_id, user_id: current_user.id)
			if vote.save
				flash.now[:notice] = 'Vote Submitted'
			else
				if current_user.votes.where(sub_id: sub_id, leader_id: leader_id).count > 0
					flash.now[:alert] = 'Error: You have already voted for this monster'
				else
					flash.now[:alert] = 'Error: Could not save vote!'
				end
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
