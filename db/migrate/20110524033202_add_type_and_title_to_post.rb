class AddTypeAndTitleToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :file_type, :string
    add_column :posts, :title, :string
  end

  def self.down
    remove_column :posts, :file_type
    remove_column :posts, :title
  end
end
