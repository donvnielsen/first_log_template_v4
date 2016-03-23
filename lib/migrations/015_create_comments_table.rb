class CreateBlockCommentsTable < ActiveRecord::Migration
  def self.up
    create_table :block_comments do |t|
      t.integer :block_id, null:false
      t.integer :seq_id, null:false
      t.text :text
    end

  end

  def self.down
    drop_table :block_comments
  end
end
