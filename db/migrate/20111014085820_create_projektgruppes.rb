class CreateProjektgruppes < ActiveRecord::Migration
  def self.up
    create_table :projektgruppes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :projektgruppes
  end
end
