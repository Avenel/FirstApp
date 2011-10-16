class CreateBuchungs < ActiveRecord::Migration
  def self.up
    create_table :buchungs do |t|
			t.integer :buchjahr, :limit => 4, :null => false
			t.integer :ktonr, :limit => 5, :null => false
			t.string :bnkreis, :limit => 2, :null => false
			t.integer :belegnr, :limit => 10, :null => false
			t.string :typ, :limit => 1, :null => false
			t.date :belegdatum
			t.date :buchdatum
			t.string :buchungstext, :limit => 50, :null => false
			t.decimal :sollbetrag, :precision => 10, :scale => 2, :default => nil, :null => true
			t.decimal :habenbetrag, :precision => 10, :scale => 2, :default => nil, :null => true
			t.integer :sollktonr, :limit => 5, :null => false, :default => 0
			t.integer :habenktonr, :limit => 5, :null => false, :default => 0
			t.decimal :wsaldoacc, :precision => 10, :scale => 2, :default => 0.00, :null => false
			t.integer :punkte, :limit => 10, :default => nil
			t.integer :psaldoacc, :limit => 10, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :buchungs
  end
end
