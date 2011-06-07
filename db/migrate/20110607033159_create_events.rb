class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :from_date
      t.string :from_time
      t.string :to_date
      t.string :to_time
      t.string :address
      t.text :content
      t.integer :user_id
      t.string :aspect_ids
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
