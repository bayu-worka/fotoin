class MomentSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user_id, :user_email, :share_url, :total_likes, :total_comments, :moment_type, :total_donation, :price

  has_many :photos, serializer: PhotoShowSerializer

  def user_email
    object.user.email
  end

  def share_url
    Rails.application.routes.url_helpers.moment_url(object)
  end

  def total_likes
    object.vote_for.size
  end

  def total_comments
    object.root_comments.size
  end
end
