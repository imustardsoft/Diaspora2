class ModifyEventsTable < ActiveRecord::Migration
  def self.up
    remove_column :events, :aspect_ids
    add_column :events, :aspect_id, :integer
    add_column :events, :equals_code, :string
  end

  def self.down
    remove_column :events, :aspect_id
    remove_column :events, :equals_code
  end
end
