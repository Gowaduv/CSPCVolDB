class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :action
      t.string :subject_class
      t.integer :subject_id
      t.references :user, index: true

      t.timestamps
    end
    
    create_table :role_permissions do |t|
      t.references :role
      t.references :permission
      t.integer :added_by_id
      t.timestamps
    end
    
    add_index(:permissions, :action)
    add_index(:permissions, [ :action, :subject_class ])
    add_index(:permissions, [ :action, :subject_class, :subject_id ])
    add_index(:role_permissions, [ :role_id, :permission_id ])
  end
end
