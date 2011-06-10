class FullContentSearchsController < ApplicationController
  def search_result
    #keyword_array = params[:content_keyword].split(" ")
    @posts = Post.where("text like '%#{params[:content_keyword]}%'")
    @events = Event.where("content like '%#{params[:content_keyword]}%' or address like '%#{params[:content_keyword]}%'")
  end
end
