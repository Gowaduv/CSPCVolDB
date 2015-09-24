require 'optparse'
namespace :schedule do |args|

  # must not use any spaces in the submission
  desc "Create schedule entries for recurring events"
  task :create_recurring, [:from_date] => :environment do |task, args|
    options = {}
    optparse = OptionParser.new(args) do |opts|
      opts.on("--from_date {from_date}", "Date to start creating Schedules") do |from_date|
        options[:from_date] = from_date
      end
      opts.on("-e", "--event_id {event_id}", "Event to create Schedules for") do |event_id|
        options[:event_id] = event_id
      end
      opts.on("-c","--calendar_id {calendar_id}", "Calendar to create Schedules for") do |calendar_id|
        options[:calendar_id] = calendar_id
      end
    end
    begin 
      optparse.parse!(ARGV[2..-1])
    rescue OptionsParser::InvalidOption => e
      puts "invalid option : e.inspect"
    end

    puts "options #{options.inspect}"
    start_date = options[:from_date].to_date || Date.today
    end_date = start_date + 90.days
    puts "start_date is #{start_date} end_date is #{end_date}"
    events = args[:event_id] ? Event.find(args[:event_id]) :
    (args[:calendar_id] ? Event.recurring.calendar(args[:calendar_id]) : Event.recurring)
    events.each do |event|
      puts "creating schedules for #{event.inspect}"
      staff_list = event.staffs
      puts "staff_list #{staff_list.inspect}"
      dates = event.recurring_schedule.occurrences_between(start_date, end_date)
      dates.each do |date|
        puts "processing date #{date}"
        staff_list.each do |staff|
          puts "finding schedule for location_id: #{event.default_location} staff_id #{staff.id} date #{date.inspect}"
          tz = date.to_time
          puts "tz #{tz.inspect}"
          schedule = Schedule.where(location_id: event.default_location, staff_id: staff.id, date: tz).first
          puts "schedule for staff #{staff.inspect} is #{schedule.inspect}"
          if schedule.nil? then
            schedule = Schedule.new(location_id: event.default_location, staff_id: staff.id, date: date)
            puts "new schedule is #{schedule.inspect}"
            if schedule.valid? then
              schedule.save
              if staff.permanent_user then
                permOffer = Offer.create(user_id: staff.permanent_user, schedule_id: schedule.id, accepted: 1, accepted_timestamp: Time.now, accepted_user_id: 1)
                puts "permOffer is #{permOffer.inspect}"
                if permOffer.valid? then
                  permOffer.save
                  schedule.offer_id = permOffer.id
                  schedule.save
                else
                  puts "permOffer is not valid! #{permOffer.inspect}"
                end
              end
            end
          end
          puts "schedule #{schedule.inspect}"
          if staff.permanent_user and schedule.offer_id.nil? then
            permOffer = Offer.where(user_id: staff.permanent_user, schedule_id: schedule.id, accepted: 1)
            if permOffer.nil? then
              permOffer = Offer.create(user_id: staff.permanent_user, schedule_id: schedule.id, accepted: 1, accepted_timestamp: Time.now, accepted_user_id: 1)
              if permOffer.valid? then
                permOffer.save
                schedule.offer_id = permOffer.id
                schedule.save
              end
            else
              schedule.offer_id = permOffer.id
              schedule.save
            end
          end            
        end      
      end           
    end    
  end
  
end
