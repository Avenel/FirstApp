class CreateEeKontos < ActiveRecord::Migration
  def self.up
    create_table :ee_kontos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ee_kontos
  end
end
