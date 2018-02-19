class Api::V1::PhotosController < Api::V1::ApiController
  before_action :authenticate_request!, only: [:like, :unlike, :check_like_status, :comments, :destroy]
  before_action :set_photo, only: [:show, :like, :unlike, :root_comments, :check_like_status, :comments, :destroy]

  # GET /photos/1
  # GET /photos/1.json
  def show
    render json: @photo, serializer: PhotoShowSerializer
  end

  def root_comments
    root_comments = @photo.root_comments
    render json: root_comments
  end

  def like
    @photo.liked_by @current_user
    render json: {message: "successfully like Photo"}, status: :ok
  end

  def unlike
    @photo.unliked_by @current_user
    render json: {message: "successfully unlike Photo"}, status: :ok
  end

  def check_like_status
    like_status = @current_user.voted_for?(@photo)
    render json: {like_status: like_status}, status: :ok
  end

  def comments
    new_comment = Comment.build_from(@photo, @current_user.id, body)
    if new_comment.save
      render json: new_comment, status: :ok
    else
      render json: {errors: new_comment.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @photo.comment_threads.find(params[:comment_id])
    if @photo.user.eql?(@current_user) || comment.user.eql?(@current_user)
      comment.destroy
      render json: {message: "successfully destroy comment"}, status: :ok
    else
      render json: {errors: {message: "You don't have authorize"}}, status: :unauthorized
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
