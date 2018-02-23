class Api::V1::MomentsController < Api::V1::ApiController
  before_action :authenticate_request!, only: [:create, :update, :destroy, :make_donation]
  before_action :set_moment, only: [:show, :make_donation]
  before_action :set_moment_owned, only: [:edit, :update, :destroy]
  before_action :validate_donation_type_moment, only: [:donation, :make_donation]

  # GET /moments
  # GET /moments.json
  def index
    moments = Moment.page(params[:page])
    render json: moments, meta: pagination_dict(moments)
  end

  # GET /moments/1
  # GET /moments/1.json
  def show
    render json: @moment, serializer: MomentTimelineSerializer, scope: {'current_user': @current_user}
  end

  # POST /moments
  # POST /moments.json
  def create
    moment = @current_user.moments.new(moment_params)

    if moment.save
      render json: moment, status: :created
    else
      render json: {errors: moment.errors}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /moments/1
  # PATCH/PUT /moments/1.json
  def update
    if @moment.update(moment_params)
      render json: @moment, status: :ok
    else
      render json: {errors: @moment.errors}, status: :unprocessable_entity
    end
  end

  # DELETE /moments/1
  # DELETE /moments/1.json
  def destroy
    @moment.destroy
    render json: {message: "Moment successfully destroy"}, status: :ok
  end

  def make_donation
    @donation = @moment.donations.new(donation_params.merge(user: @current_user))
    if @donation.save
      render json: @donation, status: :ok
    else
      render json: {errors: @donation.errors}, status: :unprocessable_entity
    end
  end

  def donation_params
    params.require(:donation).permit(:amount, :tmoney_email, :tmoney_password)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_moment
      @moment = Moment.find(params[:id])
    end

    def set_moment_owned
      @moment = @current_user.moments.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def moment_params
      params.require(:moment).permit(:title, :description, :moment_type, photos_attributes: [:id, :description, :title, :image, :_destroy])
    end

    def validate_donation_type_moment
      render json: {errors: {code: 401, message: "Hanya Moment bertipe Donasi yang dapat menerima donasi"}}, status: :bad_request unless @moment.moment_type.eql?("donation")
    end
end
