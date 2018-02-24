class AddDeletedAtToVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :votes, :deleted_at, :datetime
    add_index :votes, :deleted_at
  end
end
