class Schedule < ActiveRecord::Base
  #resourcify
  belongs_to :staff
  belongs_to :location
  has_one :event, through: :staff
  has_one :shift, through: :staff
  has_one :position, through: :staff
  has_many :users, through: :offers
  has_many :offers
  has_one :permanent, through: :staff, :foreign_key => :permanent_user
  
  scope :accepted, -> { joins(:offers).where( offers: { accepted: 1, :revoked => nil}) }
  scope :revoked, -> { joins(:offers).where( offers: { revoked: 1}) }
  scope :denied, -> { joins(:offers).where( offers: { denied: 1}) }
  scope :offered, -> { joins(:offers).where(offers: { accepted: 0, :revoked => nil, :denied => nil }) }
  
  def info 
     return "#{self.event.name} - #{self.staff.position.name} - #{date} - #{self.staff.shift.start} "
  end
  
  def to_icecube
      ics = IceCube::Schedule.new
      ics.start_time = self.date.to_date.to_time + Time.parse(self.staff.shift.start).seconds_since_midnight.seconds
      ics.duration = self.staff.shift.duration * 60
      return ics
  end

  def offered
    self.offers.where(:accepted => nil, :revoked => nil, :denied => nil)
  end

  def revoked_offer?(offer_id)
    return true if self.offers.where(:id => offer_id, :revoked => 1)
    return false    
  end
  
  def accepted_offer
    self.offers.accepted.first  # there's only one accepted offer
  end

  def user_offer(user_id)
    self.offers.where(:user_id => user_id).first
  end

  def has_offer_from?(user)
    return false if self.offers.empty?
    return true if self.offers.where(:revoked => nil).map(&:user_id).include? user.id
    return false
  end

  def has_denied_offer_from?(user)
    return false if self.offers.empty?
    return true if self.offers.where(:denied => 1).map(&:user_id).include? user.id
    return false
  end

  
  def get_user_offer_id(user)
    Rails.logger.debug("schedule.get_user_offer_id user #{user.inspect}")
    return nil if user.nil?
    return self.offers.where(:user_id => user.id).first.id # should only be one offer per user
  end
  
  def overlaps?(schedule)
    Rails.logger.debug("self is #{self.inspect}")        
    Rails.logger.debug("schedule is #{schedule.inspect}")
  end     
end
