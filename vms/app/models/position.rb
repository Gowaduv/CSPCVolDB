class Position < ActiveRecord::Base

  validates :name, presence: true
  validates :desc, presence: true, length: { in: 10..500, too_long: "%{count} is the maximum number of characters and spaces" }
  has_many :users, through: :qualifications
  has_many :qualifications
  has_many :shifts
  has_many :schedules, through: :shifts

  enum training: [ :no, :yes ]   # no is 0, yes is 1
  
  scope :entry_level, -> { where(:training => false) }

  def training? 
    return true if self.training == 'yes'
    return false
  end                      
end
