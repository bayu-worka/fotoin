class AddPriceToMoment < ActiveRecord::Migration[5.1]
  def change
    add_column :moments, :price, :decimal
  end
end
