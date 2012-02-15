class CreatePerson < ActiveRecord::Migration
  def self.up
    create_table(:Person, :primary_key => :pnr) do |t|
      # PNR PS
      t.integer :pnr, :null => false, :uniqueness => true, :limit => 10
      # Rolle                              
      t.column :rolle, "ENUM('G', 'M', 'P', 'S', 'F')" # G: Gesellschafter, M: Mitglied, P: Partner,  S: Student, F: Foerdermitglied
      # Name
      t.string :name, :null => false, :limit => 20
      # Vorname
      t.string :vorname, :null => false, :limit => 15, :default => ""
      # Geburtsdatum 
      t.date :geburtsdatum, :default => nil
      # Straße
      t.string :strasse, :limit => 50, :default => nil
      # Hausnummer
      t.string :hausnr, :limit => 10, :default => nil
      # Postleitzahl
      t.integer :plz, :limit => 5, :default => nil
      # Ort
      t.string :ort, :limit => 50, :default => nil
      # Vermerk
      t.string :vermerk, :limit => 100, :default => nil
      # E-Mail
      t.string :email, :default => nil
      # Antragsdatum
      t.date :antragsdatum , :default => nil
      # Aufnahmedatum
      t.date :aufnahmedatum, :default => nil
      # Austrittsdatum
      t.date :austrittsdatum , :default => nil
    end
        
  end

  def self.down
    drop_table :Person
  end
end
