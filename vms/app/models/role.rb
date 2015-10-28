class Role < ActiveRecord::Base
  has_many :users_roles
  has_many :users, :through => :users_roles
  has_many :role_permissions
  has_many :permissions, through: :role_permissions
  #has_and_belongs_to_many :users, :join_table => :users_roles
  #belongs_to :resource, :polymorphic => true
  
  #validates :resource_type,
  #          :inclusion => { :in => Rolify.resource_types },
  #          :allow_nil => true
  #scopify
  
end
