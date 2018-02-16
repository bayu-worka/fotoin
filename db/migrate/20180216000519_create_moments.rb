class CreateMoments < ActiveRecord::Migration[5.1]
  def change
    create_table :moments, id: :uuid do |t|
      t.string :title
      t.text :description
      t.references :user, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
