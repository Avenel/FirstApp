class CreateOZBPerson < ActiveRecord::Migration
  def self.up
    create_table(:OZBPerson, :primary_key => :id) do |t|
      # Mitgliedsnummer PS, FS
      t.integer :id, :null => false, :uniqueness => true, :limit => 10
      # Personennummer FS
      t.integer :ueberPnr, :uniqueness => true, :limit => 10
      # Passwort
      t.string :passwort, :limit => 35, :default => nil
      # PWAendDatum
      t.date :pwAendDatum, :default => nil
      # Gesperrt
      t.boolean :gesperrt, :null => false, :default => false
    end
  end

  def self.down
    drop_table :OZBPerson
  end
end