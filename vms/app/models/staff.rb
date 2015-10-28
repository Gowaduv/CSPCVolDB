class Staff < ActiveRecord::Base
  #resourcify
  belongs_to :event
  belongs_to :position
  belongs_to :shift
  has_many :schedules
  belongs_to :user
end
