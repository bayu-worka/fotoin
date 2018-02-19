class User < ApplicationRecord
  acts_as_voter
  acts_as_followable
  acts_as_follower
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :phone

  with_options dependent: :destroy do |assoc|
    assoc.has_many :photos
    assoc.has_many :moments
    assoc.has_many :comments
  end

  def followed_photos
    following_ids = all_following.map(&:id)
    Photo.where(user_id: following_ids)
  end

  def followed_moments
    following_ids = all_following.map(&:id)
    Moment.where(user_id: following_ids)
  end

  def request_otp
    self.generate_token_otp
    sms_otp = SmsOtp.new
    sms_otp.get_access_token
    sms_otp.request_otp(phone, token_otp)
  end

  def validate_otp(otp)
    sms_otp = SmsOtp.new
    sms_otp.get_access_token
    sms_otp.validate_otp(otp, token_otp)
    update(otp_status: true, token_otp: nil) if sms_otp.instance_variable_get(:@validate_status)
    sms_otp
  end

  def generate_token_otp
    self.token_otp = loop do
      random_token = SecureRandom.hex
      break random_token unless User.exists?(token_otp: random_token)
    end
    self.save
  end

  def add_point_last_month
    photos.includes(:votes_for).each do |photo|
      self.update(point: self.point + (photo.get_latest_month_like_size * 100))
    end
  end
end
