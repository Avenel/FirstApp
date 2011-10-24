class CreateProjektgruppe < ActiveRecord::Migration
  def self.up
    create_table(:Projektgruppe, :primary_key => :pgNr) do |t|
      t.integer :pgNr, :null => false, :uniqueness => true, :limit => 2
      t.string :projGruppez, :default => nil
    end
  end

  def self.down
    drop_table :projektgruppe
  end
end
