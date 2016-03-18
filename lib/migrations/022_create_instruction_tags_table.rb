class CreateInstructionTagsTable < ActiveRecord::Migration
  def self.up
    create_table :instruction_tags do |t|
      t.integer :instruction_id# null:false
      t.text :tag#, null:false
    end

  end

  def self.down
    drop_table :instruction_tags
  end
end
