class PhotoShowSerializer < ActiveModel::Serializer
  attributes :id, :description, :title, :image_url, :total_root_comments, :share_url, :total_likes, :like_status

  def image_url
    object.image.url
  end

  def total_root_comments
    object.root_comments.size
  end

  def total_likes
    object.votes_for.size 
  end

  def share_url
    Rails.application.routes.url_helpers.photo_url(object)
  end

  def like_status
    if scope
      scope[:current_user].voted_for?(object)
    else
      false
    end
  end
end
