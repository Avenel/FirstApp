class CreateVeranstaltungs < ActiveRecord::Migration
  def self.up
    create_table(:veranstaltungs, :primary_key => :vnr) do |t|
      # VNR PS
      t.integer :vnr, :null => false, :uniqueness => true, :limit => 5
      # Vid FS
      t.integer :vid, :null => false
      # vaDatum
      t.date :vaDatum, :null => false
      # vaOrt
      t.string :vaOrt, :limit => 30, :default => nil
    end
  end

  def self.down
    drop_table :veranstaltungs
  end
end
