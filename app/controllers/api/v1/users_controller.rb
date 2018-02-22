class Api::V1::UsersController < Api::V1::ApiController
  before_action :authenticate_request!, except: [:sign_in, :sign_up, :forgot_password, :show, :moments, :check_token]
  before_action :set_user_with_child, only: [:show, :moments]
  before_action :set_user, only: [:follow, :unfollow, :check_follow_status]

  def sign_in
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      auth_token = JsonWebToken.encode({email: user.email, id: user.id})
      render json: {auth_token: auth_token[:token], expire: auth_token[:expire]}, status: :ok
    else
      render json: {errors: {message: 'Invalid code / password'}}, status: :unauthorized
    end
  end

  def sign_up
    user = User.new(user_params)
    if user.save
      auth_token = JsonWebToken.encode({email: user.email, id: user.id})
      render json: {auth_token: auth_token[:token], expire: auth_token[:expire]}, status: :ok
    else
      render json: {errors: user.errors}
    end
  end

  def forgot_password
    user = User.send_reset_password_instructions({email: params[:email]})
    if user.id
      render json: {message: "email sent"}, status: :ok
    else
      render json: {errors: {message: "email not found"}}, status: :not_found
    end
  end

  def show
    render json: @user, serializer: UserSerializer, include: ['moments.photos']
  end

  def moments
    moments = @user.moments.page(params[:page])
    render json: moments, meta: pagination_dict(moments)
  end

  def follow
    @current_user.follow(@user)
    render json: {message: "successfully follow user"}, status: :ok
  end

  def unfollow
    @current_user.stop_following(@user)
    render json: {message: "successfully unfollow user"}, status: :ok
  end

  def check_follow_status
    following = @current_user.following?(@user)
    render json: {following_status: following} , status: :ok
  end

  def gallery
    moments = @current_user.moments.page(params[:page])
    render json: moments, meta: pagination_dict(moments), status: :ok
  end

  def profile
    render json: @current_user
  end

  def request_otp
    @current_user.request_otp
    render json: {message: "Otp request sent, please check your phone"}, status: :ok
  end

  def validate_otp
    response = @current_user.validate_otp(params[:otp])
    if response.instance_variable_get(:@error)
      render json: {errors: {message: response.instance_variable_get(:@error)}}, status: :ok
    else
      render json: {message: "Your phone number successfully activated"}, status: :ok
    end
  end

  def check_token
    auth_header = params[:token]
    token = auth_header.split(' ').last
    begin
      payload = JsonWebToken.decode(token)[0]
      token_status = JsonWebToken.valid_payload(payload)
    rescue
      token_status = false
    end

    if token_status
      render json: {token_status: "valid"}, status: :ok
    else
      render json: {token_status: "invalid"}, status: :ok
    end
  end

  def timeline
    moments = @current_user.followed_moments.page(params[:page])
    render json: moments, each_serializer: MomentTimelineSerializer, scope: {'current_user': @current_user}, meta: pagination_dict(moments), status: :ok
  end

  def submit_register_tmoney
    response = current_user.register_tmoney(params[:user][:pwd], params[:user][:full_name])
    render json: {message: response}
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :phone)
  end

  def set_user_with_child
    @user = User.includes(moments: :photos).find(params[:id])
  end

  def set_user
    @user = User.find(params[:id])
  end
end