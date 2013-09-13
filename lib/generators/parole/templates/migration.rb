class AddParole < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :commentable, polymorphic: true
      t.references :commenter, polymorphic: true
      t.string :role, default: 'comment'
      t.text :comment

      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id, :role]
  end

  def self.down
    drop_table :comments
  end
end
