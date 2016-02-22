class CRatingsController < ApplicationController
  before_action :set_c_rating, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :destroy]
  respond_to :html

  def index
    @c_ratings = CRating.all
    respond_with(@c_ratings)
  end

  def show
    respond_with(@c_rating)
  end

  def new
    @c_rating = CRating.new
    respond_with(@c_rating)
  end

  def edit
  end

  def create
    c_rating = CRating.new(c_rating_params)
	c_rating.user_id = current_user.id
    c_rating.save
	redirect_to detail_monsters_path(leader_id: c_rating.comment.leader_id, sub_id: c_rating.comment.sub_id, tab: 2), anchor: c_rating.comment.id, notice: flash[:notice], alert: flash[:alert]
  end

  def update
    @c_rating.update(c_rating_params)
    respond_with(@c_rating)
  end

  def destroy
    @c_rating.destroy
    respond_with(@c_rating)
  end

  private
    def set_c_rating
      @c_rating = CRating.find(params[:id])
    end

    def c_rating_params
      params.permit(:comment_id,:score)
    end
end
