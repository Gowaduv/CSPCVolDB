class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.string :start
      t.integer :duration
      t.integer :credit

      t.timestamps
    end
  end
end
