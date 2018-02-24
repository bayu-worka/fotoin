class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone, :point, :moments_count

  has_many :moments, serializer: MomentSerializer

  def moments_count
    object.moments.size
  end
end
