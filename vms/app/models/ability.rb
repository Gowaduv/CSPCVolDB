class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    user.roles.each { |role| send(role) }
    if user.roles.size == 0 then
      # default abilities
      can :read, Position
      can :read, Event
      can :read, Calendar
    end
  end

  def dir 
  # this is the admin's way to add roles
  # user can edit their own information via the devise controller
     Rails.logger.error("user #{user.inspect} has roles vcd or dir #{user.roles.inspect}")
     can :manage, :all
     can :manage, Event
     can :manage, Calendar
  end

  def vcd
    dir
  end

end
