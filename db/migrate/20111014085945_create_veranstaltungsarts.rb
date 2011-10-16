class CreateVeranstaltungsarts < ActiveRecord::Migration
  def self.up
    create_table(:veranstaltungsarts, :primary_key => :id) do |t|
      # Veranstaltungsart-id PS
      t.integer :id, :null => false, :uniqueness => true, :limit => 2
      # VABezeichnung
      t.string :vaBezeichnung, :limit => 30, :default => nil
      
    end
  end

  def self.down
    drop_table :veranstaltungsarts
  end
end
