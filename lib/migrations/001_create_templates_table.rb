class CreateTemplatesTable < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.text :app_name#, null:false
      t.integer :app_id#, null:false
    end

    add_foreign_key :blocks,:templates, on_delete: :cascade
  end

  def self.down
    drop_table :templates
  end
end
