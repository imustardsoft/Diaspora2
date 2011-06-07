class EventsController < ApplicationController
  def create
    event = Event.new(params[:event])
    event.user_id = current_user.id
    if event.save
      flash[:notice] = "Create event successful"
    else
      flash[:notice] = "Create event error"     
    end
    redirect_to aspects_path
  end
end
