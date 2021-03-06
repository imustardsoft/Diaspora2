#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user

  belongs_to :person
  validates_presence_of :person

  has_many :aspect_memberships
  has_many :aspects, :through => :aspect_memberships

  has_many :post_visibilities
  has_many :posts, :through => :post_visibilities

  validate :not_contact_for_self

  validates_uniqueness_of :person_id, :scope => :user_id

  scope :sharing, lambda {
    where(:sharing => true)
  }

  scope :receiving, lambda {
    where(:receiving => true)
  }

  def dispatch_request
    request = self.generate_request
    Postzord::Dispatch.new(self.user, request).post
    request
  end

  def generate_request
    Request.diaspora_initialize(:from => self.user.person,
                :to => self.person,
                :into => aspects.first)
  end

  def receive_post(post)
    PostVisibility.create!(:post_id => post.id, :contact_id => self.id)
    post.socket_to_user(self.user, :aspect_ids => self.aspect_ids) if post.respond_to? :socket_to_user
  end

  def contacts
    people = Person.arel_table
    incoming_aspects = Aspect.joins(:contacts).where(
      :user_id => self.person.owner_id,
      :contacts_visible => true,
      :contacts => {:person_id => self.user.person.id}).select('aspects.id')
    incoming_aspect_ids = incoming_aspects.map{|a| a.id}
    # by cloud modify search people contacts
    #similar_contacts = Person.joins(:contacts => :aspect_memberships).where(
    #  :aspect_memberships => {:aspect_id => incoming_aspect_ids}).where(people[:id].not_eq(self.user.person.id)).select('DISTINCT people.*')
    similar_contacts = Person.joins(:contacts => :aspect_memberships).where(
     :aspect_memberships => {:aspect_id => incoming_aspect_ids}).select('DISTINCT people.*')
  end

  def mutual?
    self.sharing && self.receiving
  end

  private
  def not_contact_for_self
    if person_id && person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end
end

