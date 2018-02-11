class AddPhoneAndOtpStatusToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :phone, :string
    add_column :users, :otp_status, :boolean, default: false
  end
end
