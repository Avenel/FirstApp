class CreateTeilnahme < ActiveRecord::Migration
  def self.up
    create_table(:Teilnahme, :id => false) do |t|
      # Pnr PS1, FS
      t.integer :pnr, :null => false, :limit => 10
      # Vnr PS2, FS
      t.integer :vnr, :null => false, :limit => 5
      # Teilnahmeart
      t.column :teilnArt, "ENUM('a', 'e', 'u')" # a: anwesend, e: entschuldigt, u: unentschuldigt       
    end
  end

  def self.down
    drop_table :Teilnahme
  end
end
