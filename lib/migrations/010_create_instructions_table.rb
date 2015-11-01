class CreateInstructionsTable < ActiveRecord::Migration
  def self.up
    create_table :instructions do |t|
      t.integer :block_id, null:false
      t.integer :seq_id, null:false
      t.text :parm,null:false
      t.text :arg
      t.boolean :is_fname, null:false, default:false
    end

  end

  def self.down
    drop_table :instructions
  end
end
