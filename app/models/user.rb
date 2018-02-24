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
    assoc.has_many :donations
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
      random_token = SecureRandom.hex(6)
      break random_token unless User.exists?(token_otp: random_token)
    end
    self.save
  end

  def add_point_last_month
    photos.includes(:votes_for).each do |photo|
      point_added = photo.get_latest_month_like_size * 100
      self.update(point: self.point + point_added)
      self.send_sms("Selamat anda mendapatkan #{point_added} point dari Fotoin, ayo upload momen mu dan bagikan untuk dapat lebih banyak point") if point_added > 0
    end
  end

  def send_sms(message)
    sms_otp = SmsOtp.new
    sms_otp.get_access_token
    sms_otp.send_sms(self.phone, message)
  end

  def register_tmoney(pwd, full_name)
    tmoney = Tmoney.new
    tmoney.sign_up(self.email, pwd, full_name, self.phone)
    if tmoney.instance_variable_get(:@register_status)
      tmoney.email_verification
      tmoney.instance_variable_get(:@message)
    else
      tmoney.instance_variable_get(:@error)["resultDesc"]
    end
  end

  def redeem_tmoney(redeem_point)
    begin
      redeem_point = redeem_point.to_i
      if redeem_point <= point
        tmoney = Tmoney.new
        tmoney.generate_signature(ENV["TMONEY_EMAIL"])
        tmoney.sign_in(ENV["TMONEY_EMAIL"], ENV["TMONEY_PASSWORD"])
        tmoney.transfer_p2p(1, self.email, redeem_point)

        unless tmoney.instance_variable_get(:@error)
          update(point: point - redeem_point)
          send_sms("Selamat anda berhasil menukar #{redeem_point} menjadi balance tmoney")
          true
        else
          false
        end
      else
        false
      end
    rescue
      false
    end
  end
end
