class MomentSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :photos, serializer: PhotoSerializer
end
