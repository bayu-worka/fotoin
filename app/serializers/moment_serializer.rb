class MomentSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user_id, :user_email

  has_many :photos, serializer: PhotoSerializer

  def user_email
    object.user.email
  end
end
