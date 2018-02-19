class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :description, :title, :image_url

  def image_url
    object.image.url
  end
end
