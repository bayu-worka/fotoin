class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, except: [:gallery, :otp, :request_otp, :validate_otp, :profile]

  def show
    @user = User.find(params[:id])
    @moments = @user.moments.page(params[:page])
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

  def gallery
    @moments = current_user.moments.page(params[:page])
  end

  def otp    
  end

  def request_otp
    current_user.request_otp
    redirect_to otp_users_path, notice: 'Otp code sent, please check your phone.'
  end

  def validate_otp
    response = current_user.validate_otp(params[:otp])
    if response.instance_variable_get(:@error)
      redirect_to otp_users_path, notice: response.instance_variable_get(:@error)
    else
      redirect_to root_path, notice: "Your phone number successfully activated"
    end
  end

  def profile
    @user = current_user
    @moments = @user.moments.page(params[:page])
    render "show"
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
