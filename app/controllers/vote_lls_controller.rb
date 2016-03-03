class VoteLlsController < ApplicationController
  before_action :set_vote_ll, only: [:show, :edit, :update, :destroy]

  # GET /vote_lls
  # GET /vote_lls.json
  def index
    @vote_lls = VoteLl.all
  end

  # GET /vote_lls/1
  # GET /vote_lls/1.json
  def show
  end

  # GET /vote_lls/new
  def new
    @vote_ll = VoteLl.new
  end

  # GET /vote_lls/1/edit
  def edit
  end

  # POST /vote_lls
  # POST /vote_lls.json
  def create
	monster_id = params[:monster_id]
	monster_name = params[:monster_name]
	monster = fetch_monster_by_one(monster_id, monster_name)
	current = params[:current_id]
	rating = params[:rating]
	
	if monster == nil then monster = create_monster(monster_id, monster_name) end
	
	if is_number?(rating) and rating.to_i <= Rails.application.config.vote_rating_max and rating.to_i >= 0
		if monster != nil
			rating = rating.to_i
			leader_id1 = current.to_i
			leader_id2 = monster.id.to_i
			if Monster.where(id: leader_id1).count == 1 and Monster.where(id: leader_id2).count == 1
				if user_voted_default_month(leader_id1, leader_id2, "ll")
					if rating > 0

						vote = fetch_user_vote_by_default_month(leader_id1, leader_id2, "ll")
						if vote.update(score: rating.to_i)
							flash.now[:notice] = 'Vote Updated'
						else
							flash.now[:alert] = 'Error: Could not save vote!'
						end
					else
						vote = fetch_user_vote_by_default_month(leader_id1, leader_id2, "ll")
						vote.destroy
						flash.now[:notice] = 'Vote Removed'
					end
				else
					if rating > 0
						vote = VoteLl.new(score:rating.to_i,leaders: [leader_id1, leader_id2], user_id: current_user.id)
						if vote.save
							flash.now[:notice] = 'Vote Submitted'
						else
							flash.now[:alert] = 'Error: Could not save vote!'
						end
					else
						flash.now[:alert] = 'Error: Could not save vote!'
					end
				end
			else
				flash.now[:alert] = 'Error: ' + leader_id1.to_s + ' is not a valid monster id'
			end
		else
			flash.now[:alert] = 'Error: Invalid monster name'
		end
	end
	redirect_to monster_path(current), notice: flash[:notice], alert: flash[:alert]
  end

  # PATCH/PUT /vote_lls/1
  # PATCH/PUT /vote_lls/1.json
  def update
    respond_to do |format|
      if @vote_ll.update(vote_ll_params)
        format.html { redirect_to @vote_ll, notice: 'Vote ll was successfully updated.' }
        format.json { render :show, status: :ok, location: @vote_ll }
      else
        format.html { render :edit }
        format.json { render json: @vote_ll.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vote_lls/1
  # DELETE /vote_lls/1.json
  def destroy
    @vote_ll.destroy
    respond_to do |format|
      format.html { redirect_to vote_lls_url, notice: 'Vote ll was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote_ll
      @vote_ll = VoteLl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_ll_params
      params.require(:vote_ll).permit(:leaders, :user_id, :score)
    end
end
