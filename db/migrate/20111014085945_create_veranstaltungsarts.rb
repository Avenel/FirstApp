class CreateVeranstaltungsarts < ActiveRecord::Migration
  def self.up
    create_table :veranstaltungsarts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :veranstaltungsarts
  end
end
