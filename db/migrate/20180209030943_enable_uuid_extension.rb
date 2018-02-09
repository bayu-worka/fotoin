class EnableUuidExtension < ActiveRecord::Migration[5.1]
  def change
    if ActiveRecord::Base.connection.adapter_name.eql?("PostgreSQL")
      enable_extension 'uuid-ossp'
      enable_extension 'pgcrypto'
    end
  end
end
