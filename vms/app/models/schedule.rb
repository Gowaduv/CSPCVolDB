class Schedule < ActiveRecord::Base
  belongs_to :staff
  belongs_to :location
  has_one :event, through: :staff
  has_one :shift, through: :staff
  has_one :position, through: :staff
  has_many :users, through: :offers
  has_many :offers
  has_one :permanent, through: :staff, :foreign_key => :permanent_user
  
  scope :accepted, -> { joins(:offers).where( offers: { accepted: 1}) }
  scope :revoked, -> { joins(:offers).where( offers: { revoked: 1}) }
  scope :denied, -> { joins(:offers).where( offers: { denied: 1}) }
  
  def info 
     return "#{self.event.name} - #{self.staff.position.name} - #{date} - #{self.staff.shift.start} "
  end
  
  def accepted_offer
    self.offers.where(accepted:1).first  # there's only one accepted offer
  end

  def has_offer_from?(user)
    return false if self.offers.empty?
    return true if self.offers.map(&:user_id).include? user.id
    return false
  end
  
  def overlaps?(schedule)
    Rails.logger.debug("self is #{self.inspect}")        
    Rails.logger.debug("schedule is #{schedule.inspect}")
  end     
end
