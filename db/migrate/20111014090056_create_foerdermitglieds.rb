class CreateFoerdermitglieds < ActiveRecord::Migration
  def self.up
    create_table :foerdermitglieds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :foerdermitglieds
  end
end
