class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.references :user, index: true
      t.references :schedule, index: true
      t.integer :accepted
      t.datetime :accepted_timestamp
      t.integer :accepted_user_id
      t.integer :denied
      t.datetime :denied_timestamp
      t.integer :denied_user_id
      t.integer :revoked
      t.datetime :revoke_timestamp 
      t.timestamps
    end
  end
end
