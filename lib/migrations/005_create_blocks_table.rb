class CreateBlocksTable < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.text :name,null:false
      t.integer :seq_id, null:false
      t.boolean :is_report, null:false, default:false
      t.boolean :contains_fname, null:false, default:false
    end

  end

  def self.down
    drop_table :blocks
  end
end
