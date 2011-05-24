class ServiceUser < ActiveRecord::Base

  belongs_to :person
  belongs_to :contact
  belongs_to :service
  belongs_to :invitation

  before_save :attach_local_models

  private
  def attach_local_models
    service_for_uid = Services::Facebook.where(:type => service.type.to_s, :uid => self.uid).first
    if !service_for_uid.blank? && (service_for_uid.user.person.profile.searchable)
      self.person = service_for_uid.user.person 
    else
      self.person = nil
    end

    if self.person
      self.contact = self.service.user.contact_for(self.person)
    end

    self.invitation = Invitation.joins(:recipient).where(:sender_id => self.service.user_id,
                                                            :users => {:invitation_service => self.service.provider,
                                                                       :invitation_identifier => self.uid}).first
  end
end
