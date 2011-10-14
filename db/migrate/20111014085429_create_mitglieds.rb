class CreateMitglieds < ActiveRecord::Migration
  def self.up
    create_table :mitglieds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :mitglieds
  end
end
