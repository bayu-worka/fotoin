class ActsAsCommentableWithThreadingMigration < ActiveRecord::Migration[5.1]
  def self.up
    create_table :comments, force: true, id: :uuid do |t|
      t.uuid :commentable_id
      t.string :commentable_type
      t.string :title
      t.text :body
      t.string :subject
      t.uuid :user_id, :null => false
      t.uuid :parent_id
      t.integer :lft, :rgt
      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    drop_table :comments
  end
end
