class Photo < ApplicationRecord
  acts_as_votable
  acts_as_commentable
  mount_uploader :image, PhotoUploader

  belongs_to :user
  belongs_to :moment
  validates_presence_of :image
  before_validation :assign_user

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

  def add_point_to_owner
    user.update(point: user.point + 1)
    user.send_sms("selamat anda mendapatkan 1 point dari Fotoin untuk Foto dari moment #{moment.title}")
  end

  private
  def assign_user    
    self.user = moment.user if moment
  end
end
