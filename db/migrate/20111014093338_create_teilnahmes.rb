class CreateTeilnahmes < ActiveRecord::Migration
  def self.up
    create_table :teilnahmes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :teilnahmes
  end
end
