class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
 
    # default abilities
    can :read, Calendar
    can :read, Event
    can :read, Location
    can :read, Position
    can :listing, Event
    
          
    if user.has_any_role?({:name => :vcd, :name => :dir})
       Rails.logger.error("user #{user.inspect} has roles vcd or dir #{user.roles.inspect}")
       can :manage, :all
       can :manage, Calendar
       can :manage, Event
       can :manage, Location
       can :manage, Offer
       can :manage, Position
       can :manage, Qualification
       can :manage, Schedule
       can :manage, Shift
       can :manage, Staff
       can :manage, User
     end
    if user.has_any_role?({:name => :volunteer})
      can :create, Offer
    end
     
  end

end
