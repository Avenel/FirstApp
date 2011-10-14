class CreateZeKontos < ActiveRecord::Migration
  def self.up
    create_table :ze_kontos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ze_kontos
  end
end
