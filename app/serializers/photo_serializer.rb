class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :description, :title, :image_url, :share_url

  def image_url
    object.image.url
  end

  def share_url
    Rails.application.routes.url_helpers.photo_url(object)
  end
end
