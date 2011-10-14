class CreateKontenklasses < ActiveRecord::Migration
  def self.up
    create_table :kontenklasses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :kontenklasses
  end
end
