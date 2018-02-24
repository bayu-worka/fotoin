class Api::V1::UsersController < Api::V1::ApiController
  before_action :authenticate_request!, except: [:sign_in, :sign_up, :forgot_password, :show, :moments, :check_token]
  before_action :set_user_with_child, only: [:show, :moments]
  before_action :set_user, only: [:follow, :unfollow, :check_follow_status]

  swagger_controller :users, 'Users'

  swagger_api :sign_in do
    summary 'Sign in User'
    param :form, :email, :string, :required, "User Email"
    param :form, :password, :string, :required, "User Password"
  end
  def sign_in
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      auth_token = JsonWebToken.encode({email: user.email, id: user.id})
      render json: {auth_token: auth_token[:token], expire: auth_token[:expire], id: user.id, email: user.email}, status: :ok
    else
      render json: {errors: {code: 801, message: 'Invalid code / password'}}, status: :unauthorized
    end
  end

  swagger_api :sign_up do
    summary 'Sign Up User'
    param :form, :email, :string, :required, "User Email"
    param :form, :password, :string, :required, "User Password"
    param :form, :phone, :string, :required, "User Password"
  end
  def sign_up
    user = User.new(user_params)
    if user.save
      auth_token = JsonWebToken.encode({email: user.email, id: user.id})
      render json: {auth_token: auth_token[:token], expire: auth_token[:expire], id: user.id, email: user.email}, status: :ok
    else
      render json: {errors: user.errors}
    end
  end

  swagger_api :forgot_password do
    summary 'forgot password User'
    param :form, :email, :string, :required, "User Email"
  end
  def forgot_password
    user = User.send_reset_password_instructions({email: params[:email]})
    if user.id
      render json: {message: "email sent"}, status: :ok
    else
      render json: {errors: {message: "email not found"}}, status: :not_found
    end
  end

  swagger_api :show do
    summary 'Returns single user'
    param :path, :id, :string, :required, "User Id"
  end
  def show
    render json: @user, serializer: UserSerializer, include: ['moments.photos']
  end

  swagger_api :moments do
    summary 'Returns moments of single user'
    param :path, :id, :string, :required, "User Id"
    param :query, :page, :integer, :optional, "Page number"
  end
  def moments
    moments = @user.moments.page(params[:page])
    render json: moments, meta: pagination_dict(moments)
  end

  swagger_api :follow do
    summary 'Follow user'
    param :path, :id, :string, :required, "User Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def follow
    @current_user.follow(@user)
    render json: {message: "successfully follow user"}, status: :ok
  end

  swagger_api :unfollow do
    summary 'unfollow user'
    param :path, :id, :string, :required, "User Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def unfollow
    @current_user.stop_following(@user)
    render json: {message: "successfully unfollow user"}, status: :ok
  end

  swagger_api :check_follow_status do
    summary 'check_follow_status user'
    param :path, :id, :string, :required, "User Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def check_follow_status
    following = @current_user.following?(@user)
    render json: {following_status: following} , status: :ok
  end

  swagger_api :gallery do
    summary 'Returns gallery of current user'
    param :query, :page, :integer, :optional, "Page number"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def gallery
    # moments = @current_user.moments.page(params[:page])
    # render json: moments, meta: pagination_dict(moments), status: :ok
    render json: @current_user, include: ['moments.photos'], status: :ok
  end

  swagger_api :profile do
    summary 'Returns current user profile'
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def profile
    render json: @current_user
  end

  swagger_api :request_otp do
    summary 'request otp'
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def request_otp
    @current_user.request_otp
    render json: {message: "Otp request sent, please check your phone"}, status: :ok
  end

  swagger_api :validate_otp do
    summary 'validate otp'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, :otp, :string, :required, "otp code"
  end
  def validate_otp
    response = @current_user.validate_otp(params[:otp])
    if response.instance_variable_get(:@error)
      render json: {errors: {code: 401, message: response.instance_variable_get(:@error)}}, status: :ok
    else
      render json: {message: "Validate success"}, status: :ok
    end
  end

  swagger_api :check_token do
    summary 'check token'
    param :form, :token, :string, :required, "token"
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

  swagger_api :timeline do
    summary 'Returns timeline of current user'
    param :query, :page, :integer, :optional, "Page number"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def timeline
    moments = if params[:donation]
      @current_user.followed_moments.donation.page(params[:page])
    else
      @current_user.followed_moments.page(params[:page])
    end
    render json: moments, each_serializer: MomentTimelineSerializer, scope: {'current_user': @current_user}, meta: pagination_dict(moments), status: :ok
  end

  swagger_api :submit_register_tmoney do
    summary 'Returns timeline of current user'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, "user[pwd]", :string, :required, "Password for tmoney"
    param :form, "user[full_name]", :string, :required, "full_name for tmoney"
  end
  def submit_register_tmoney
    response = current_user.register_tmoney(params[:user][:pwd], params[:user][:full_name])
    render json: {message: response}
  end

  swagger_api :redeem_tmoney do
    summary 'redeem tmoney'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, "point", :integer, :required, "tmoney password"
  end
  def redeem_tmoney
    if @current_user.redeem_tmoney(params[:point])
      render json: {message: "Penukaran point berhasil"}
    else
      render json: {errors: {code: 400, message: "Penukaran point gagal"}}, status: :bad_request
    end
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