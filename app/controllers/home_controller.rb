class HomeController < ApplicationController
  def index
    @photos = current_user.followed_photos if user_signed_in?
  end
end
