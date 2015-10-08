class Offer < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule

  scope :accepted, -> { where(accepted: true, :revoked => nil) }
  scope :revoked, -> { where(revoked: true) }
  scope :pending, -> { where(accepted: false, revoked: false, denied: false) }
  scope :denied, -> { where(denied: true) }
  scope :valid_offers, -> { where("offers.accepted = 1 or offers.revoked is NULL and offers.denied is NULL") }  
  
  def overlap?
    # find user's other offers
    otherOffers = User.find(self.user_id).offers.valid_offers
    return false if otherOffers.empty?
    # compare them with the current offer
    proposedSchedule = Schedule.find(self.schedule_id).to_icecube
    otherOffers.each do |oOffer|
      oSched = oOffer.schedule.to_icecube
      if proposedSchedule.occurring_between?(oSched.start_time, oSched.end_time)
        return true
      end          
    end 
    return false
  end
  
end
