class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user

  def show
  end

  def follow
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user, notice: 'User was successfully followed.' }
      format.json { head :no_content }
    end
  end

  def unfollow
    current_user.stop_following(@user)
    respond_to do |format|
      format.html { redirect_to @user, notice: 'Photo was successfully unfollowed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
