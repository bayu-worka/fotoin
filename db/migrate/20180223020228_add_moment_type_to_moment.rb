class AddMomentTypeToMoment < ActiveRecord::Migration[5.1]
  def change
    add_column :moments, :moment_type, :integer, default: 0
  end
end
