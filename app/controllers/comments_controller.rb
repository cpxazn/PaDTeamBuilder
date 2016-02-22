class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create]
  respond_to :html

  def index
    @comments = Comment.all
    respond_with(@comments)
  end

  def show
    respond_with(@comment)
  end

  def new
    @comment = Comment.new
    respond_with(@comment)
  end

  def edit
  end

  def create
    comment = Comment.new(comment_params)
	comment.user_id = current_user.id
    if comment.save
		flash.now[:notice] = 'Comment created'
	else
		flash.now[:alert] = 'Error: Could not save comment!'
	end
    redirect_to detail_monsters_path(leader_id: comment.leader_id, sub_id: comment.sub_id, tab: 2), anchor: comment.id, notice: flash[:notice], alert: flash[:alert]
  end

  def update
    @comment.update(comment_params)
    respond_with(@comment)
  end

  def destroy
    @comment.comment = "[deleted]"
	@comment.save
    redirect_to detail_monsters_path(leader_id: @comment.leader_id, sub_id: @comment.sub_id, tab: 2, anchor: @comment.id)
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:user_id, :leader_id, :sub_id, :comment, :parent_id)
    end
end
