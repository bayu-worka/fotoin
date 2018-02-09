class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos, id: :uuid do |t|
      t.string :image
      t.text :description
      t.references :user, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
