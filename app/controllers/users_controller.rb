class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, except: [:gallery, :otp, :request_otp, :validate_otp, :profile, :register_tmoney, :submit_register_tmoney, :redeem_point, :tmoney, :redeem_tmoney]

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

  def register_tmoney; end

  def submit_register_tmoney
    notice = current_user.register_tmoney(params[:user][:pwd], params[:user][:full_name])
    redirect_to profile_users_path, notice: notice
  end

  def redeem_point; end

  def tmoney; end

  def redeem_tmoney
    if current_user.redeem_tmoney(params[:point])
      redirect_to profile_users_path, notice: "Penukaran point berhasil"
    else
      redirect_to tmoney_users_path(point: params[:point]), notice: "Penukaran point gagal"
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
