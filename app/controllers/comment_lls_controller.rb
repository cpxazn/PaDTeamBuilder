class CommentLlsController < ApplicationController
  before_action :set_comment, only: [:destroy]
  before_action :authenticate_user!, only: [:create, :destroy]
  respond_to :html

  def destroy
	if current_user.id = @comment_ll.user_id
		@comment_ll.comment = "[deleted]"
		@comment_ll.save
	end
    redirect_to detail_monsters_path(leader_id: @comment_ll.leaders[0], sub_id: @comment_ll.leaders[1], tab: 2,  type: "ll", anchor: @comment_ll.id)
  end
  
  private
    def set_comment
      @comment_ll = CommentLl.find(params[:id])
    end
end
