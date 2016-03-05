class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :destroy]
  respond_to :html


  def create
	m1_id = params["leader_id"]
	m2_id = params["sub_id"]
	comment_text = params["comment_text"]
	t = params["type"]
	
    comment = Comment.model_gen(t).new
	if t == "ls"
		comment.leader_id = m1_id
		comment.sub_id = m2_id
	elsif t == "ll"
		comment.leaders = [m1_id, m2_id].sort
	else
		render_404
		return
	end
	
	comment.comment = comment_text
	comment.user_id = current_user.id
    if comment.save
		flash.now[:notice] = 'Comment created'
	else
		flash.now[:alert] = params["comment_text"]
	end
    redirect_to detail_monsters_path(leader_id: m1_id, sub_id: m2_id, tab: 2, type: t), anchor: comment.id, notice: flash[:notice], alert: flash[:alert]
  end

  def destroy
	if current_user.id == @comment.user_id or current_user.admin
		@comment.comment = "[deleted]"
		@comment.save
	end
    redirect_to detail_monsters_path(leader_id: @comment.leader_id, sub_id: @comment.sub_id, type: "ls", tab: 2, anchor: @comment.id)
  end

  def update
    @comment.update(comment_params)
    respond_with(@comment)
  end
  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:user_id, :leader_id, :sub_id, :comment, :parent_id, :type)
    end
	
end
