class Event < ActiveRecord::Base
  validates :from_date, :presence => true
  validates :from_time, :presence => true
  validates :to_date, :presence => true
  validates :to_time, :presence => true
  validates :address, :presence => true
  validates :content, :presence => true
  validates :user_id, :presence => true
  validates :aspect_id, :presence => true

  def equals_code
    Digest::SHA1.hexdigest((Time.new.to_i + Kernel::rand(999).to_i).to_s)
  end
end
