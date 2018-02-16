class AddMomentToPhoto < ActiveRecord::Migration[5.1]
  def change
    add_reference :photos, :moment, foreign_key: true, type: :uuid, index: true
  end
end
