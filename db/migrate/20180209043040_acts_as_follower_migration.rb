class ActsAsFollowerMigration < ActiveRecord::Migration[5.1]
  def self.up
    create_table :follows, force: true, id: :uuid do |t|
      t.references :followable, polymorphic: true, null: false, type: :uuid
      t.references :follower,   polymorphic: true, null: false, type: :uuid
      t.boolean :blocked, default: false, null: false
      t.timestamps
    end

    add_index :follows, ["follower_id", "follower_type"],     name: "fk_follows"
    add_index :follows, ["followable_id", "followable_type"], name: "fk_followables"
  end

  def self.down
    drop_table :follows
  end
end
