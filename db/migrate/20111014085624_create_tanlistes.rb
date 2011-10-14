class CreateTanlistes < ActiveRecord::Migration
  def self.up
    create_table :tanlistes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :tanlistes
  end
end
