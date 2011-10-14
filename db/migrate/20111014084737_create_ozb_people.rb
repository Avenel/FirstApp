class CreateOzbPeople < ActiveRecord::Migration
  def self.up
    create_table :ozb_people do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ozb_people
  end
end
