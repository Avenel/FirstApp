class CreateKkVerlaufs < ActiveRecord::Migration
  def self.up
    create_table :kk_verlaufs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :kk_verlaufs
  end
end
