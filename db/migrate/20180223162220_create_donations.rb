class CreateDonations < ActiveRecord::Migration[5.1]
  def change
    create_table :donations, id: :uuid do |t|
      t.references :moment, foreign_key: true, type: :uuid, index: true
      t.references :user, foreign_key: true, type: :uuid, index: true
      t.decimal :amount

      t.timestamps
    end
  end
end
