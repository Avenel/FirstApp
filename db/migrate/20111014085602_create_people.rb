class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :pnr, :presence => true, :uniqueness => true, :length => {:maximum => 10 }
      t.column "rolle", :enum, :limit => [:G, :M, :P, :S, :F]
      t.string :name, :presence => true, :length =>{:maximum => 20}
      t.string :vorname, :presence => true, :length =>{:maximum => 15}
      t.date :geburtsdatum
      t.string :strasse, :length => {:maximum => 50}
    end
    
  end

  def self.down
    drop_table :people
  end
end
