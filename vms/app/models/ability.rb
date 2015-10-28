class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
 
    # default abilities
    can :read, Calendar
    can :read, Event
    can :read, Location
    can :read, Position

    #can :manage, User, roles: { id: user.role_ids }    
          
    if user.has_any_role?({:name => :vcd, :name => :dir})
       Rails.logger.error("user #{user.inspect} has roles vcd or dir #{user.roles.inspect}")
       can :manage, :all
       can :manage, Calendar
       can :manage, Event
       can :manage, Location
       can :manage, Offer
       can :manage, Permission
       can :manage, Position
       can :manage, Qualification
       can :manage, Role
       can :manage, Schedule
       can :manage, Shift
       can :manage, Staff
       can :manage, User
       can :manage, UsersRole
    end
     
    if user.has_any_role?({:name => :volunteer})
      Rails.logger.error("user #{user.inspect} has roles volunteer #{user.roles.inspect}")
      can :create, Offer
      can :update, Offer
      can :listing, Event
    end

    # get the roles permissions from the database
    user.roles.each do |role|
      Rails.logger.debug("user is #{user.inspect} processing role #{role.inspect}")
      role.permissions.each do |permission|
        if permission.subject_id.nil?
          can permission.action.to_sym, permission.subject_class.constantize
        else
          can permission.action.to_sym, permission.subject_class.constantize, :id => permission.subject_id
        end      
      end
    end

    # get the user's permssions from the database
    user.permissions.each do |permission|
      if permission.subject_id.nil?
        can permission.action.to_sym, permission.subject_class.constantize
      else
        can permission.action.to_sym, permission.subject_class.constantize, :id => permission.subject_id
      end
    end

    Rails.logger.debug("user at the end of ability #{user.inspect}")     
  end

end
