class RolifyCreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name
      t.string :desc
      #t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:users_roles) do |t|
      t.references :user
      t.references :role
      t.integer :added_by_id
      t.string :subject_class
      t.integer :subject_id
      t.timestamps
    end

    add_index(:roles, :name)
    #add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:users_roles, [ :user_id, :role_id ])
    add_index(:users_roles, [ :user_id, :role_id, :subject_id ])
    add_index(:users_roles, [ :user_id, :role_id, :subject_class, :subject_id ], name: 'index_user_roles_resources')
   end
end
