class CreateVeranstaltungs < ActiveRecord::Migration
  def self.up
    create_table :veranstaltungs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :veranstaltungs
  end
end
