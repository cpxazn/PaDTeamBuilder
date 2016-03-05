class CRatingsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  respond_to :html

  def find_rating(m1_id, m2_id, t)
	case t
		when "ls"
			return Comment.where(leader_id: m1_id, sub_id: m2_id, user_id: current_user.id).first
		when "ll"
			return Comment.where(Monster.query_gen(m1_id, m2_id, t) + "and user_id = ?", m1_id, m2_id, current_user.id).first
	end
  end
  def create
	t = params["type"]
	if t != nil		
		p = c_rating_params
		
		if t == "ls"
			c_rating = CRating.model_gen(t).new(p)
			query = {comment_id: p["comment_id"], user_id: current_user.id}
			comment = c_rating.comment
			m1 = comment.leader_id
			m2 = comment.sub_id
		elsif t == "ll"
			c_rating = CRating.model_gen(t).new(comment_ll_id: p["comment_id"], score: p["score"])
			query = {comment_ll_id: p["comment_id"], user_id: current_user.id}
			comment = c_rating.comment_ll
			m1 = comment.leaders[0]
			m2 = comment.leaders[1]
		end
		score = p["score"].to_i
		old = CRating.model_gen(t).where(query).first
		if score == 1 or score == -1
			if current_user.id != comment.user_id then
				if old != nil then
					old.score = score
					if old.save
						flash.now[:notice] = 'Vote updated'
					else
						flash.now[:alert] = 'Could not rate comment'
					end
				else
					c_rating.user_id = current_user.id
					if c_rating.save
						flash.now[:notice] = 'Comment rated'
					else
						flash.now[:alert] = 'Could not rate comment'
					end
				end
			else
				flash.now[:alert] = 'Could not rate comment'
			end
		else
			flash.now[:alert] = 'Could not rate comment'
		end
		redirect_to detail_monsters_path(leader_id: m1, sub_id: m2, tab: 2, type: t), anchor: comment.id, notice: flash[:notice], alert: flash[:alert]
	else
		render_404
	end
  end

  def update
    @c_rating.update(c_rating_params)
    respond_with(@c_rating)
  end

  private
    def c_rating_params
      params.permit(:comment_id,:score)
    end
end
