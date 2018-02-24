class Api::V1::MomentsController < Api::V1::ApiController
  before_action :authenticate_request!, only: [:create, :update, :destroy, :make_donation]
  before_action :set_moment, only: [:show, :make_donation]
  before_action :set_moment_owned, only: [:edit, :update, :destroy]
  before_action :validate_donation_type_moment, only: [:donation, :make_donation]

  swagger_controller :moments, 'Moments'

  # GET /moments
  # GET /moments.json
  swagger_api :index do
    summary 'Returns all moments'
    param :query, :page, :integer, :optional, "Page number"
  end
  def index
    moments = Moment.page(params[:page])
    render json: moments, meta: pagination_dict(moments)
  end

  # GET /moments/1
  # GET /moments/1.json
  swagger_api :show do
    summary 'Returns single moments'
    param :path, :id, :string, :required, "Moment Id"
  end
  def show
    render json: @moment, serializer: MomentTimelineSerializer, scope: {'current_user': @current_user}
  end

  swagger_api :create do
    summary 'Create Moment'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, "moment[title]", :string, :required, "Moment title"
    param :form, "moment[description]", :string, :required, "Moment description"
    param :form, "moment[photos_attributes][0][id]", :string, :required, "Photo Id"
    param :form, "moment[photos_attributes][0][description]", :string, :required, "Photo description"
    param :form, "moment[photos_attributes][0][title]", :string, :required, "Photo title"
    param :form, "moment[photos_attributes][0][image]", :file, :required, "Photo file"
    param :form, "moment[photos_attributes][0][_destroy]", :boolean, :required, "Destroy status"
  end
  def create
    moment = @current_user.moments.new(moment_params)

    if moment.save
      render json: moment, status: :created
    else
      render json: {errors: moment.errors}, status: :unprocessable_entity
    end
  end

  swagger_api :update do
    summary 'update Moment'
    param :path, :id, :string, :required, "Moment Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, "moment[title]", :string, :required, "Moment title"
    param :form, "moment[description]", :string, :required, "Moment description"
    param :form, "moment[photos_attributes][0][id]", :string, :required, "Photo Id"
    param :form, "moment[photos_attributes][0][description]", :string, :required, "Photo description"
    param :form, "moment[photos_attributes][0][title]", :string, :required, "Photo title"
    param :form, "moment[photos_attributes][0][image]", :file, :required, "Photo file"
    param :form, "moment[photos_attributes][0][_destroy]", :boolean, :required, "Destroy status"
  end
  def update
    if @moment.update(moment_params)
      render json: @moment, status: :ok
    else
      render json: {errors: @moment.errors}, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary 'destroy Moment'
    param :path, :id, :string, :required, "Moment Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
  end
  def destroy
    @moment.destroy
    render json: {message: "Moment successfully destroy"}, status: :ok
  end

  swagger_api :make_donation do
    summary 'make donation to Moment'
    param :path, :id, :string, :required, "Moment Id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :form, "donation[amount]", :float, :required, "amount of donation"
    param :form, "donation[tmoney_email]", :string, :required, "tmoney email"
    param :form, "donation[tmoney_password]", :string, :required, "tmoney password"
  end
  def make_donation
    @donation = @moment.donations.new(donation_params.merge(user: @current_user))
    if @donation.save
      render json: @donation, status: :ok
    else
      render json: {errors: @donation.errors}, status: :unprocessable_entity
    end
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

    def donation_params
      params.require(:donation).permit(:amount, :tmoney_email, :tmoney_password)
    end

    def validate_donation_type_moment
      render json: {errors: {code: 401, message: "Hanya Moment bertipe Donasi yang dapat menerima donasi"}}, status: :bad_request unless @moment.moment_type.eql?("donation")
    end
end
