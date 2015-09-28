class Shift < ActiveRecord::Base
  belongs_to :staffs
  
  def start_with_duration
    "#{start.to_time.strftime("%I:%M%p")} - #{duration} minutes"
  end
end
