class User < ApplicationRecord
  acts_as_voter
  acts_as_followable
  acts_as_follower
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :phone
  has_many :photos, dependent: :destroy

  def followed_photos
    following_ids = all_following.map(&:id)
    Photo.where(user_id: following_ids)
  end

  def request_otp
    sms_otp = SmsOtp.new
    sms_otp.get_access_token
    sms_otp.request_otp(phone)
  end

  def validate_otp(otp)
    sms_otp = SmsOtp.new
    sms_otp.get_access_token
    sms_otp.validate_otp(otp)
    update(otp_status: true) if sms_otp.instance_variable_get(:@validate_status)
    sms_otp
  end
end
