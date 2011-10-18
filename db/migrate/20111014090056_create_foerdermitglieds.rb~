class CreateFoerdermitglieds < ActiveRecord::Migration
  def self.up
    create_table(:foerdermitglieds, :primary_key => :pnr) do |t|
      # Personalnummer PS, FS
      t.integer :pnr, :null => false, :uniqueness => true, :limit => 10
      # Region
      t.string :region, :limit => 30, :default => nil
      # Förderbeitrag
      t.decimal :foerderbeitrag, :scale => 2, :precision => 5, :default => nil
    end
  end

  def self.down
    drop_table :foerdermitglieds
  end
end
