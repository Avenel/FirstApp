class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table(:people, :primary_key => :pnr) do |t|
      # Index
      t.integer :pnr, :presence => true, :uniqueness => true, :length => {:maximum => 10 }
      # Rolle
      t.column "rolle", :enum, :limit => [:G, :M, :P, :S, :F]
      # Name
      t.string :name, :presence => true, :length =>{:maximum => 20}
      # Vorname
      t.string :vorname, :presence => true, :length =>{:maximum => 15}, :default => ""
      # Geburtsdatum 
      t.date :geburtsdatum
      # Straße
      t.string :strasse, :length => {:maximum => 50}
      # Hausnummer
      t.string :hausnr, :length => {:maximum => 10}
      # Postleitzahl
      t.integer :plz, :length => {:maximum => 5}
      # Ort
      t.string :ort, :length => {:maximum => 50}
      # Vermerk
      t.string :vermerk, :length => {:maximum => 100}
      # E-Mail
      t.string :email
      # Antragsdatum
      t.date :antragsdatum 
      # Aufnahmedatum
      t.date :aufnahmedatum
      # Austrittsdatum
      t.date :austrittsdatum 
    end
        
  end

  def self.down
    drop_table :people
  end
end
