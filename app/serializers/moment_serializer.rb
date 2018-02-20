class MomentSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user_id, :user_email, :share_url

  has_many :photos, serializer: PhotoSerializer

  def user_email
    object.user.email
  end

  def share_url
    Rails.application.routes.url_helpers.moment_url(object)
  end
end
