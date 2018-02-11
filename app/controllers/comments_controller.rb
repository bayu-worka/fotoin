class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable

  def create
    @new_comment = Comment.build_from(@photo, current_user.id, body)

    respond_to do |format|
      if @new_comment.save
        format.html  { redirect_to @photo, notice: 'Comment was successfully added.' }
      else
        format.html  { render 'photos/show' }
      end
    end
  end

  def reply
    @new_comment = Comment.build_from(@photo, current_user.id, body)
    @comment = Comment.find(params[:comment_id])
    respond_to do |format|
      if @new_comment.save
        @new_comment.move_to_child_of(@comment)
        format.html  { redirect_to @photo, notice: 'Comment was successfully added.' }
      else
        format.html  { render 'photos/show' }
      end
    end
  end

  def destroy
  end

  private
  def set_commentable
    @photo = Photo.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def body
    comment_params[:body]
  end
end
