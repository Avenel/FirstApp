class CreateGesellschafters < ActiveRecord::Migration
  def self.up
    create_table :gesellschafters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :gesellschafters
  end
end
