class CreateTelefons < ActiveRecord::Migration
  def self.up
    create_table :telefons do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :telefons
  end
end
