#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Photo < Post
  require 'carrierwave/orm/activerecord'
  mount_uploader :processed_image, ProcessedImage
  mount_uploader :unprocessed_image, UnprocessedImage
  ############# by  cloud #################
  mount_uploader :document_uploader, DocumentUploader
  ##############################

  xml_attr :remote_photo_path
  xml_attr :remote_photo_name

  xml_attr :text
  xml_attr :status_message_guid

  belongs_to :status_message

  attr_accessible :text, :pending
  validate :ownership_of_status_message

  before_destroy :ensure_user_picture
  after_create :queue_processing_job

  def ownership_of_status_message
    message = StatusMessage.find_by_id(self.status_message_id)
    if status_message_id && message
      self.diaspora_handle == message.diaspora_handle
    else
      true
    end
  end

  ############## by cloud ##################
#  def self.diaspora_initialize(params = {})
#    photo = super(params)
#    image_file = params.delete(:user_file)
#    photo.random_string = ActiveSupport::SecureRandom.hex(10)
#    photo.unprocessed_image.store! image_file
#    photo.update_remote_path
#    photo
#  end

  def self.diaspora_initialize(params = {})
    photo = super(params)
    image_file = params.delete(:user_file)
    photo.random_string = ActiveSupport::SecureRandom.hex(10)
    photo.title = params.delete(:title)
    if ["jpg", "jpeg", "gif", "png"].include? photo.title.split(".")[-1]
      photo.file_type = "image"
      photo.unprocessed_image.store! image_file
    else
      photo.document_uploader.store! image_file
    end
    photo.update_remote_path
    photo
  end

  ###########end#############

  def not_processed?
    processed_image.path.nil?
  end

  def processed?
    !processed_image.path.nil?
  end

  def update_remote_path
    #by cloud
    whether_image = (self.file_type == "image")
    image_link = whether_image ? self.unprocessed_image.url : self.document_uploader.url
    #end
    #unless self.unprocessed_image.url.match(/^https?:\/\//)
    unless image_link.match(/^https?:\/\//)
      pod_url = AppConfig[:pod_url].dup
      pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
      
      #remote_path = "#{pod_url}#{self.unprocessed_image.url}"
      #### by cloud
      remote_path = whether_image ? "#{pod_url}#{self.unprocessed_image.url}" : "#{pod_url}#{self.document_uploader.url}"
      ## end
    else
      #by cloud
      if whether_image
        remote_path = self.unprocessed_image.url
      else
        remote_path = self.document_uploader.url
      end
      ###### end
    end

    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def status_message_guid
    if self.status_message
      self.status_message.guid
    else
      nil
    end
  end

  def status_message_guid= new_sm_guid
    self.status_message= StatusMessage.where(:guid => new_sm_guid).first
  end

  def url(name = nil)
    if remote_photo_path
      name = name.to_s + '_' if name
      remote_photo_path + name.to_s + remote_photo_name
    elsif not_processed?
      #by cloud
      if self.file_type == "image"
        unprocessed_image.url(name)
      else
        document_uploader.url
      end
    else
      processed_image.url(name)
    end
  end

  def ensure_user_picture
    profiles = Profile.where(:image_url => url(:thumb_large))
    profiles.each { |profile|
      profile.image_url = nil
      profile.save
    }
  end

  def thumb_hash
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => nil}
  end

  def queue_processing_job
    Resque.enqueue(Job::ProcessPhoto, self.id)
  end

  def process
    return false if self.processed? || (!unprocessed_image.path.nil? && unprocessed_image.path.include?('.gif'))
    processed_image.store!(unprocessed_image) #Ultra naive
    save!
  end

  def mutable?
    true
  end

  ### by cloud
#  def as_json(opts={})
#    {
#    :photo => {
#      :id => self.id,
#        :url => self.url,
#        :thumb_small => self.url(:thumb_small),
#        :text => self.text
#      }
#    }
#  end

  def as_json(opts={})
    {
    :photo => {
      :title => self.title,
      :id => self.id,
        :url => self.url,
        :thumb_small => self.url(:thumb_small),
        :text => self.text,
        :file_type => self.file_type
      }
    }
  end

  ## end

  scope :on_statuses, lambda { |post_ids|
    where(:status_message_id => post_ids)
  }

  ### cloud add method
  def is_image_type?
    self.file_type == "image" ? true : false
  end

  # end

end
