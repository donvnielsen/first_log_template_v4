class CreateTemplatesTable < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.text :app_name#, null:false
      t.integer :app_id#, null:false
    end

  end

  def self.down
    drop_table :templates
  end
end
