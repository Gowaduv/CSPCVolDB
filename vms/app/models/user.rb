class User < ActiveRecord::Base
  #rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [ :login ]
  validates :username,
    :presence => true,
    :uniqueness => { :case_sensitive => false }
  
  has_many :qualifications  
  has_many :positions, through: :qualifications
  has_many :permanent_positions, through: :staffs, :foreign_key => :permanent_user
  has_many :offers
  has_many :schedules, through: :offers
  has_many :events, through: :schedules
  has_many :permissions
  has_many :users_roles
  has_many :roles, :through => :users_roles   


  # QUALIFICATIONS STUFF
  def qualified?(position_name)
    return true if Position.entry_level.include?(Position.find_by_name(position_name)) # positions open to anyone
    return true if self.positions.include?(Position.find_by_name(position_name)) # positions specific to this user
    return false    
  end
  
  def add_qual(position_name)
    posit = Position.find_by_name(position_name)
    qual = Qualification.find_or_create_by(:position => posit, :user => self) do |qual|
      qual.status = "Good" if qual.status.nil?
      qual.count = 0 if qual.count.nil?     
    end
    qual
  end
  
  def remove_qual(position_name)
    posit = Position.find_by_name(position_name)
    qual = Qualification.find_by_position_id_and_user_id(posit, self)
    if qual then
      if Qualification.delete(qual.id)
        return true
      else
        return false
      end
    end
  end
  
  
  # ROLE STUFF
  def add_role(role_name, resource = nil)
    role = Role.find_or_create_by(:name => role_name.to_s)
    ur = UsersRole.find_or_create_by(:role => role, :user => self)    
    role
  end
  alias_method :grant, :add_role
  
  def has_role?(role_name, resource = nil)
    if new_record?
      role_array = self.roles.detect { |r|
        r.name.to_s == role_name.to_s &&
          (self.users_roles.resource == resource ||
           resource.nil? ||
           (resource == :any && self.users_roles.resource.present?))
      }
    else
      if resource.nil? then
        role_array = self.roles.where(name: role_name)
      else
        role_array = self.roles.includes(:users_roles).where(:roles => {name: role_name}, 
          :users_roles => {:subject_class => resource.is_a?(Class) ? resource.to_s : resource.class.name, 
          :subject_id => resource.id})
      end
      #Rails.logger.debug("has_role? role_array #{role_array.inspect}")
    end

    return false if role_array.nil?
    role_array != []
  end

  def has_any_role?(*args)  # may not work?
    if new_record?
      args.any? { |r| self.has_role?(r) }
    else
      Rails.logger.debug("args #{args}")
      self.roles.where(*args).size > 0
    end
  end
    
  def has_all_roles?(*args)  # may not work?                              
    args.each do |arg|
      if arg.is_a? Hash
        return false if !self.has_role?(arg[:name], arg[:resource])
      elsif arg.is_a?(String) || arg.is_a?(Symbol)
        return false if !self.has_role?(arg)
      else
        raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
      end
    end
    true
  end
    
  
  # LOGIN STUFF
  def after_sign_in_path_for(user)
    user.admin? ? admin_dashboard_path : root_path 
  end

  # make it so that a user can login with their username, email, or member_number    
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value OR lower(member_number) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end
  
  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email || self.member_number
  end
  # end login conditions code
end
