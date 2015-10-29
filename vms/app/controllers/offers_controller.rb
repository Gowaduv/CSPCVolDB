class OffersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 

  respond_to :html, :js, :json

  def index
    if (params[:user_id]) then
      @offers = User.find(params[:user_id]).offers
    else
      @offers = Offer.all
    end
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
    check_user_match(offer_params[:user_id]) or return
    # check qualifications
    Rails.logger.debug("offers:create user is #{current_user.id} #{offer_params[:user_id]}")
    
 
    # create offer
    @offer = Offer.where(:user_id => offer_params[:user_id], :schedule_id => offer_params[:schedule_id]).first
    if (@offer.nil?) then
      @offer = Offer.new(offer_params) if @offer.nil?
    else
      @offer.revoked = nil
      @offer.revoke_timestamp = nil
    end 
    if (@offer.overlap?) then
      @offer.errors.add(:base, "You have already signed up for an overlapping shift.")
      respond_to do |format|
        format.html { respond_with(@offer) }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
        format.js # handled in create.js.erb
      end
    else   
      @offer.save
      respond_to do |format|
        format.html { respond_with(@offer) }
        format.json { render json: @offer }
        format.js  
      end
    end
  end

  def update
    Rails.logger.debug("offers:update user is #{current_user.id} #{offer_params[:user_id]}")
    check_user_match(offer_params[:user_id]) or return
    params = offer_params
    @schedule = @offer.schedule
    if params[:accepted].present? then
      params[:accepted_user_id] = current_user.id
      params[:accepted_timestamp] = Time.now
      s = @offer.schedule
      s.offer_id = @offer.id
      s.save
    elsif params[:denied].present? then
      params[:denied_user_id] = current_user.id
      params[:denied_timestamp] = Time.now
    elsif params[:revoked].present?
      if @offer.accepted? then
        params[:accepted] = nil
        params[:accepted_timestamp] = nil
        params[:accepted_user_id] = nil
      end      
      params[:revoke_timestamp] = Time.now
      @schedule.offer_id = nil
      @schedule.save
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
      params.require(:offer).permit(:user_id, :schedule_id, :accepted, :revoked, :denied)
    end
end
