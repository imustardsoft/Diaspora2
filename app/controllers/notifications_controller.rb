#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json


  def update
    note = Notification.where(:recipient_id => current_user.id, :id => params[:id]).first
    if note
      note.update_attributes(:unread => false)
      render :nothing => true
    else
      render :nothing => true, :status => 404
    end
  end

  def index
    @aspect = :notification
    @notifications = Notification.find(:all, :conditions => {:recipient_id => current_user.id},
                                       :order => 'created_at desc', :include => [:target, {:actors => :profile}]).paginate :page => params[:page], :per_page => 25
    @group_days = @notifications.group_by{|note| I18n.l(note.created_at, :format => I18n.t('date.formats.fullmonth_day')) }
    respond_with @notifications
  end

  def read_all
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
    redirect_to aspects_path
  end

  ##### by cloud and reject or approve by email 
  def reject_or_approve
    notification = Notification.find(params[:id])
    if params[:status] == "approve"
      contact_receive = Contact.find(:first, :conditions => ["user_id = #{current_user.id} and person_id = #{params[:id]}"])
      contact_share = Contact.find(:first, :conditions => ["user_id = #{params[:id]} and person_id = #{current_user.id}"])
      contact_receive.update_attribute(:receiving, true)
      contact_share.update_attribute(:sharing, true)
    elsif params[:status] == "reject"

    end
    notification.update_attribute(:unread, false)
    redirect_to notifications_path
  end
  
end
