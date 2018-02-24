class Order < ApplicationRecord
  belongs_to :moment
  belongs_to :user

  validate :moment_should_be_merch
  validate :tmoney_should_be_successfully

  after_create :send_sms_notification

  attr_accessor(:tmoney_email, :tmoney_password)

  private
  def moment_should_be_merch
    errors.add(:moment, "type should be merch") unless moment.merch?
  end

  def tmoney_should_be_successfully
    tmoney = Tmoney.new
    tmoney.generate_signature(tmoney_email)
    tmoney.sign_in(tmoney_email, tmoney_password)
    tmoney.transfer_p2p(1, moment.user.email, moment.price)
    errors.add(:tmoney_email, tmoney.instance_variable_get(:@error)) if tmoney.instance_variable_get(:@error)
  end

  def send_sms_notification
    moment_owner = moment.user
    moment_owner.send_sms("Selamat merch #{moment.title} anda telah terjual")
  end
end
