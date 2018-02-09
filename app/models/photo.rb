class Photo < ApplicationRecord
  acts_as_votable
  acts_as_commentable
  mount_uploader :image, PhotoUploader

  belongs_to :user
  validates_presence_of :image, :title
end
