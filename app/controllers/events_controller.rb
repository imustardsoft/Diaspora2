class EventsController < ApplicationController
  def create
    code = Event.equals_code
    params[:aspect_ids].split(',').each do |aspect_id|
      event = Event.new(params[:event])
      event.aspect_id = aspect_id
      event.user_id = current_user.id
      event.equals_code = code
      event.save
    end
    flash[:notice] = "Create event successful"
#    event = Event.new(params[:event])
#    event.user_id = current_user.id
#    if event.save
#      flash[:notice] = "Create event successful"
#    else
#      flash[:notice] = "Create event error"
#    end
    redirect_to aspects_path
  end
end
