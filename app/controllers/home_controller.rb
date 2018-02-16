class HomeController < ApplicationController
  def index
    @moments = if user_signed_in?
      current_user.followed_moments.page(params[:page])
    else
      Moment.order("RANDOM()").limit(3)
    end
  end
end
