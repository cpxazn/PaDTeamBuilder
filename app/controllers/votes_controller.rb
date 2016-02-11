class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]

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
	if monster.all.count == 1
		monster = monster.first
		vote = Vote.new(score:1,leader_id: params[:leader_id], sub_id: monster.id, user_id: 1)
		vote.save
	end

	#uts params[:monster_name]
	
	redirect_to monster_path(params[:leader_id])
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
