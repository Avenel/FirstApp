class CreateGesellschafter < ActiveRecord::Migration
  def self.up
    create_table(:Gesellschafter, :primary_key => :mnr) do |t|
      # Mitgliedsnummer PS, FS
      t.integer :mnr, :null => false, :uniqueness => true, :limit => 10
      # Finanzamz Steuernummer 
      t.string :faSteuerNr, :limit => 15, :default => nil
      # Finanzamt Laufende Nr
      t.string :faLfdNr, :limit => 20, :default => nil
      # WohnsitzFinanzamt
      t.string :wohnsitzFinanzamt, :limit => 50, :default => nil
      # Notar Personalnummer
      t.integer :notarPnr, :limit => 10, :default => nil
      # BeurkDatum
      t.date :beurkDatum, :default => nil
    end
  end

  def self.down
    drop_table :Gesellschafter
  end
end
