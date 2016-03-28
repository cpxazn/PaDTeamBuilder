class NewsController < ApplicationController
  before_action :set_news, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :destroy, :edit, :new, :update, :show]
  before_action :check_admin, only: [:create, :destroy, :edit, :new, :update, :show]
  
  # GET /news
  # GET /news.json
  def index
	@title = "News"
    @pinned = News.where(pinned:true).order(:created_at)
	@updates = News.where(pinned:false).order(created_at: :desc).limit(Rails.application.config.news_display_max)
  end
  def about
	@title = "About"
  end
  def privacy
	@title = "Privacy"
  end
  # GET /news/1
  # GET /news/1.json
  def show
	@title = @news
  end

  # GET /news/new
  def new
    @title = "Create News"
  end

  # GET /news/1/edit
  def edit
	@title = "Edit News " + @news.id.to_s
  end

  # POST /news
  # POST /news.json
  def create
	@title = "Create News"
    @news = News.new(news_params)

    respond_to do |format|
      if @news.save
        format.html { redirect_to @news, notice: 'News was successfully created.' }
        format.json { render :show, status: :created, location: @news }
      else
        format.html { render :new }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news/1
  # PATCH/PUT /news/1.json
  def update
    respond_to do |format|
      if @news.update(news_params)
        format.html { redirect_to @news, notice: 'News was successfully updated.' }
        format.json { render :show, status: :ok, location: @news }
      else
        format.html { render :edit }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news.destroy
    respond_to do |format|
      format.html { redirect_to news_index_url, notice: 'News was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
	def check_admin
		if not current_user.admin
			redirect_to root_path
		end
	end
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      @news = News.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def news_params
      params.require(:news).permit(:title, :news, :user_id, :pinned)
    end
end
