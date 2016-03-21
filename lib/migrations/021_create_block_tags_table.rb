class CreateBlockTagsTable < ActiveRecord::Migration
  def self.up
    create_table :block_tags do |t|
      t.integer :block_id, null:false
      t.text :tag, null:false
    end

  end

  def self.down
    drop_table :block_tags
  end
end
