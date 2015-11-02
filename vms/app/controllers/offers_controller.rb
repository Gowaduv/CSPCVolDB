class OffersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => :update

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
    set_offer
    Rails.logger.debug("offers:update user is #{current_user.id} #{offer_params[:user_id]}")
    #check_user_match(offer_params[:user_id]) or redirect_to(action: listing) and return 
    Rails.logger.debug("offers:update offer is #{@offer.inspect}")
    params = offer_params
    params.delete :user_id  # the submitted user_id is the current_user.id for auth purposes
    Rails.logger.debug(" params #{params.inspect}")
    @schedule = @offer.schedule
    Rails.logger.debug("params accepted is #{params[:accepted]}")
    if params[:accepted] then
      if params[:accepted].to_i == 1 then
        Rails.logger.debug("accepted is 1, so adding!")
        params[:accepted_user_id] = current_user.id
        params[:accepted_timestamp] = Time.now
        @schedule.offer_id = @offer.id
      else
        Rails.logger.debug("accepted is 0, so removing!")
        # remove accepted info from offer and unset schedule id
        params[:accepted_user_id] = nil
        params[:accepted_timestamp] = nil
        params[:accepted] = nil
        @schedule.offer_id = nil        
      end
      params[:denied] = nil
      params[:denied_user_id] = nil
      params[:denied_timestamp] = nil
    elsif params[:denied].present? then
      params[:denied_user_id] = current_user.id
      params[:denied_timestamp] = Time.now
      params[:accepted] = nil
      params[:accepted_user_id] = nil
      params[:accepted_timestamp] = nil
    elsif params[:revoked].present?
      if @offer.accepted? then
        params[:accepted] = nil
        params[:accepted_timestamp] = nil
        params[:accepted_user_id] = nil
      end      
      params[:revoke_timestamp] = Time.now
      @schedule.offer_id = nil
    end
    Rails.logger.debug("offer in update #{@offer.inspect}")
    Rails.logger.debug("params in update #{params.inspect}")
    @offer.assign_attributes(params)
    Rails.logger.debug("offer in update after assign #{@offer.inspect}")
    if can? :update, @offer then
      Rails.logger.debug("offer:update can update")
      # if we're approving a shift then find all other approved shifts and remove
      if (@offer.accepted == 1 and @schedule.accepted_offer) then
        old_accepted = @schedule.accepted_offer
        old_accepted.accepted = nil
        old_accepted.accepted_user_id = nil
        old_accepted.accepted_timestamp = nil
        old_accepted.save      
      end
      @schedule.save
      @offer.save
      respond_to do |format|
        format.html { redirect_to action: index }
        format.json { head :ok }
        format.js
      end
    else
      Rails.logger.debug("offer:update can NOT update")
      respond_to do |format|
        format.html { redirect_to action: index }
        format.json { head :ok }
        format.js
      end      
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
