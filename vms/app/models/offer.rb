class Offer < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule

  scope :accepted, -> { where(accepted: true, :revoked => nil) }
  scope :revoked, -> { where(revoked: true, :accepted => nil) }
  scope :pending, -> { where(accepted: nil, revoked: nil, denied: nil) }
  scope :denied, -> { where(denied: true) }
  scope :canceled_shift, -> { where(accepted: true, revoked: true) }
  # accepted+revoked = canceled shift;  revoked only = canceled offer;  denied = admin refused offer
  scope :valid_offers, -> { where("offers.accepted = 1 and offers.revoked is NULL or offers.revoked is NULL and offers.denied is NULL") }
  
  def revoked?
    return true if self.revoked
    return false
  end
  
  def denied?
    return true if self.denied
    return false
  end
  
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
