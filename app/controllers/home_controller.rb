class HomeController < ApplicationController
  def index
    @photos = if user_signed_in?
      current_user.followed_photos.page(params[:page])
    else
      Photo.order("RANDOM()").limit(3)
    end
  end
end
