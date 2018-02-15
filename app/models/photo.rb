class Photo < ApplicationRecord
  acts_as_votable
  acts_as_commentable
  mount_uploader :image, PhotoUploader

  belongs_to :user
  validates_presence_of :image, :title

  def get_latest_month_like
    votes_for.where(created_at: Time.now.last_month.at_beginning_of_month..Time.now.last_month.end_of_month)
  end

  def get_this_month_like
    votes_for.where(created_at: Time.now.at_beginning_of_month..Time.now.end_of_month)
  end

  def get_latest_month_like_size
    get_latest_month_like.size
  end

  def get_this_month_like_size
    get_this_month_like.size
  end
end
