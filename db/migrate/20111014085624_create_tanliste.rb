class CreateTanliste < ActiveRecord::Migration
  def self.up
    create_table(:Tanliste, :id => false) do |t|  
       # Mitgliedsnummer PS1, FS
       t.integer :mnr, :null => false, :limit => 10    
       # Listennummer PS2, FS
       t.integer :listNr, :null => false, :limit => 2
       # Status 
       t.column :status, "ENUM('n', 'd', 'a')"  
    end
  end

  def self.down
    drop_table :Tanliste
  end
end
