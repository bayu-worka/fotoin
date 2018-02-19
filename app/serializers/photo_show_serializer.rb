class PhotoShowSerializer < ActiveModel::Serializer
  attributes :id, :description, :title, :image_url, :total_root_comments

  def image_url
    object.image.url
  end

  def total_root_comments
    object.root_comments.size
  end
end
