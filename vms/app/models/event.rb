class Event < ActiveRecord::Base
  #resourcify
  #include IceCube
  
  belongs_to :calendar
  belongs_to :location, :foreign_key => :default_location
  has_many :staffs
  has_many :schedules, through: :staffs
  #has_many :users, through: {:schedules => :offers} ??   
    
  validates :name, :presence => true
  #validates :schedule_yaml, :presence => true
  validates :calendar_id, :presence => true

  scope :calendar, -> (calendar_id) { where calendar_id: calendar_id }
  scope :recurring, -> { where.not(schedule_yaml: '')}

  def recurring_rule=(ruleHash)
    if ruleHash.match("{}") then
        self.schedule_yaml = IceCube::Schedule.new.to_yaml
    end  
    if RecurringSelect.is_valid_rule?(ruleHash) then
      #Rails.logger.debug("recurring_rule= self #{self.inspect}")
      ics = IceCube::Schedule.new
      ics.start_time = self.open_time
      ics.start_date = self.open_time
      rule = RecurringSelect.dirty_hash_to_rule(ruleHash)
      #Rails.logger.debug("recurring_rule= rule #{rule.inspect}")
      ics.add_recurrence_rule(rule)
      #Rails.logger.debug("recurring_rule= ics #{ics.inspect}")
      self.schedule_yaml = ics.to_yaml
    end  
  end
  
  def recurring_schedule
    if self.schedule_yaml.nil? then
      #Rails.logger.debug("recurring_schedule setting schedule to nil")
      return IceCube::Schedule.new
    else
      #Rails.logger.debug("recurring_schedule schedule_yaml #{schedule_yaml.inspect}")
      value = IceCube::Schedule.from_yaml(self.schedule_yaml)
      #Rails.logger.debug("value #{value.inspect}")
      return value
    end
  end  
  
  def recurring_rule
    #Rails.logger.debug("recurring_rule #{self.inspect}")
    if self.schedule_yaml.nil? then
      #Rails.logger.debug("setting schedule to nil")
      return IceCube::Schedule.new
    else
      #Rails.logger.debug("recurring_rule schedule_yaml #{schedule_yaml.inspect}")
      value = IceCube::Schedule.from_yaml(self.schedule_yaml)
      #Rails.logger.debug("recurring_rule value #{value.inspect}")
      rule = value.recurrence_rules.first
      #Rails.logger.debug("recurring_rule rule #{rule.inspect}")      
      return rule.to_hash 
    end
  end
    
  def calendar_item(date_start, date_end)
    items = Array.new
    IceCube::Schedule.from_yaml(self.schedule_yaml).occurrences_between(date_start.to_time, date_end.to_time).each do |date|
      #Rails.logger.debug("calendar_item date #{date.inspect}")
      item = { 
          title: name, 
          date: date,
          url: Rails.application.routes.url_helpers.event_path(self),
          color: self.calendar.color,
          start: date,
          end:  date + self.duration.minutes,
          event_id: id,
          textColor: "black"                                       
        }
      #Rails.logger.debug("calendar_itme item #{item.inspect}")
     items << item    
    end
    #Rails.logger.debug("calendar_item items #{items.inspect}")
    return items    
    
  end   

  def listing_item(date_start, date_end)
    items = Hash.new
    IceCube::Schedule.from_yaml(self.schedule_yaml).occurrences_between(date_start.to_time, date_end.to_time).each do |date|
      Rails.logger.debug("listing_item date #{date.inspect}")
      item = { 
          title: name, 
          date: date,
          start: date,
          end:  date + self.duration.minutes,
          event_id: id,
          event: self                                       
        }
      Rails.logger.debug("listing_itme item #{item.inspect}")
     items[date.to_date] = Array.new if items[date].nil?
     items[date.to_date] << item    
    end
    Rails.logger.debug("listing_item items #{items.inspect}")
    return items    
    
  end 
        
  def non_recurring_rule; 1; end
end



