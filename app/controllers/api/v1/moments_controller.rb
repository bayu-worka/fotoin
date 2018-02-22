class Api::V1::MomentsController < Api::V1::ApiController
  before_action :authenticate_request!, only: [:create, :update, :destroy]
  before_action :set_moment, only: [:show]
  before_action :set_moment_owned, only: [:edit, :update, :destroy]

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
    render json: @moment
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
      params.require(:moment).permit(:title, :description, photos_attributes: [:id, :description, :title, :image, :_destroy])
    end
end
