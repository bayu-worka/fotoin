class Api::V1::PhotosController < Api::V1::ApiController
  before_action :authenticate_request!, only: [:like, :unlike, :check_like_status, :comments, :destroy]
  before_action :set_photo, only: [:show, :like, :unlike, :root_comments, :check_like_status, :comments, :destroy]

  swagger_controller :photos, 'Photos'

  swagger_api :show do
    summary 'Show Single Photo'
    param :path, :id, :string, :required, "Photo Id"
  end
  def show
    render json: @photo, serializer: PhotoShowSerializer
  end

  swagger_api :root_comments do
    summary 'Show Comments of photo'
    param :path, :id, :string, :required, "Photo Id"
  end
  def root_comments
    root_comments = @photo.root_comments
    render json: root_comments
  end

  swagger_api :like do
    summary 'Like photo'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :path, :id, :string, :required, "Photo Id"
  end
  def like
    @photo.liked_by @current_user
    render json: {message: "successfully like Photo"}, status: :ok
  end

  swagger_api :unlike do
    summary 'Like photo'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :path, :id, :string, :required, "Photo Id"
  end
  def unlike
    @photo.unliked_by @current_user
    render json: {message: "successfully unlike Photo"}, status: :ok
  end

  swagger_api :check_like_status do
    summary 'Like photo'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :path, :id, :string, :required, "Photo Id"
  end
  def check_like_status
    like_status = @current_user.voted_for?(@photo)
    render json: {like_status: like_status}, status: :ok
  end

  swagger_api :comments do
    summary 'comment photo'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :path, :id, :string, :required, "Photo Id"
    param :form, "comment[body]", :string, :required, "Comment body"
  end
  def comments
    new_comment = Comment.build_from(@photo, @current_user.id, body)
    if new_comment.save
      render json: new_comment, status: :ok
    else
      render json: {errors: new_comment.errors}, status: :unprocessable_entity
    end
  end

  swagger_api :destroy do
    summary 'destroy comment photo'
    param :header, 'Authorization', :string, :required, 'Authentication token'
    param :path, :id, :string, :required, "Photo Id"
    param :path, :comment_id, :string, :required, "Comment Id"
  end
  def destroy
    comment = @photo.comment_threads.find(params[:comment_id])
    if @photo.user.eql?(@current_user) || comment.user.eql?(@current_user)
      comment.destroy
      render json: {message: "successfully destroy comment"}, status: :ok
    else
      render json: {errors: {code: 401, message: "You don't have authorize"}}, status: :unauthorized
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:image, :description, :title)
    end

    def comment_params
      params.require(:comment).permit(:body)  
    end

    def body
      comment_params[:body]
    end
end
