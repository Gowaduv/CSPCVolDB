class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  respond_to :html, :js, :json

  def index
    @offers = Offer.all
    respond_with(@offers)
  end

  def show
    respond_with(@offer)
  end

  def new
    @offer = Offer.new
    respond_with(@offer)
  end

  def edit
  end

  def create
    @offer = Offer.new(offer_params)
    @offer.save
    respond_to do |format|
      format.html { respond_with(@offer) }
      format.json { render json: @offer }
      format.js  
    end
  end

  def update
    params = offer_params
    if params[:accepted].present? then
      params[:accepted_id] = current_user.id
      params[:accepted_timestamp] = Time.now
      s = @offer.schedule
      s.
    elsif params[:denied].present? then
      params[:denied_id] = current_user.id
      params[:denied_timestamp] = Time.now
    elsif params[:revoked].present?
      params[:revoke_timestamp] = Time.now
    end
    @offer.update(params)
    respond_to do |format|
      format.html { redirect_to action: index }
      format.json { head :ok }
      format.js
    end
  end

  def destroy
    @schedule = @offer.schedule
    @offer.destroy
    respond_to do |format|
      format.html { redirect_to action: "index" }
      format.json { head :ok }
      format.js
    end
  end

  private
    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(:user_id, :schedule_id, :accepted)
    end
end
