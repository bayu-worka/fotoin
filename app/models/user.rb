class User < ApplicationRecord
  acts_as_voter
  acts_as_followable
  acts_as_follower
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :photos, dependent: :destroy

  def followed_photos
    following_ids = all_following.map(&:id)
    Photo.where(user_id: following_ids)
  end
end
