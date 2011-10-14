class CreateBankverbindungs < ActiveRecord::Migration
  def self.up
    create_table :bankverbindungs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :bankverbindungs
  end
end
