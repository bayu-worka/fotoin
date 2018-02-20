class PhotoShowSerializer < ActiveModel::Serializer
  attributes :id, :description, :title, :image_url, :total_root_comments, :share_url

  def image_url
    object.image.url
  end

  def total_root_comments
    object.root_comments.size
  end

  def share_url
    Rails.application.routes.url_helpers.photo_url(object)
  end
end
