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
    @vote_ll = VoteLl.new(vote_ll_params)

    respond_to do |format|
      if @vote_ll.save
        format.html { redirect_to @vote_ll, notice: 'Vote ll was successfully created.' }
        format.json { render :show, status: :created, location: @vote_ll }
      else
        format.html { render :new }
        format.json { render json: @vote_ll.errors, status: :unprocessable_entity }
      end
    end
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
