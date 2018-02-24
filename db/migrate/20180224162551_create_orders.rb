class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :moment, foreign_key: true, type: :uuid, index: true
      t.references :user, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
