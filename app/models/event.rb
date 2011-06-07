class Event < ActiveRecord::Base
  validates :from_date, :presence => true
  validates :from_time, :presence => true
  validates :to_date, :presence => true
  validates :to_time, :presence => true
  validates :address, :presence => true
  validates :content, :presence => true
  validates :user_id, :presence => true
  validates :aspect_ids, :presence => true
end
