class CreateOzbKontos < ActiveRecord::Migration
  def self.up
    create_table :ozb_kontos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ozb_kontos
  end
end
