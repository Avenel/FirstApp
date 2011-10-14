class CreateBuchungOnlines < ActiveRecord::Migration
  def self.up
    create_table :buchung_onlines do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :buchung_onlines
  end
end
