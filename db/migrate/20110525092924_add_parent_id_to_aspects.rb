class AddParentIdToAspects < ActiveRecord::Migration
  def self.up
    add_column :aspects, :parent_id, :integer
  end

  def self.down
    remove_column :aspects, :parent_id
  end
end
