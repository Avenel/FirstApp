class CreateBuergschafts < ActiveRecord::Migration
  def self.up
    create_table :buergschafts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :buergschafts
  end
end
