class CreateTans < ActiveRecord::Migration
  def self.up
    create_table :tans do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :tans
  end
end
