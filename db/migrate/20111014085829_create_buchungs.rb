class CreateBuchungs < ActiveRecord::Migration
  def self.up
    create_table :buchungs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :buchungs
  end
end
