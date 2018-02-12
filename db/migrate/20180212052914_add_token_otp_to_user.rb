class AddTokenOtpToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :token_otp, :string
  end
end
