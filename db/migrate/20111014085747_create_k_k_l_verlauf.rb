class CreateKKLVerlauf < ActiveRecord::Migration
  def self.up
    create_table(:KKLVerlauf) do |t|
      # Kontonummer FS
      t.integer :ktoNr, :null => false, :limit => 5
      # KKLAblaufDatum 
      t.date :kklAbDatum, :null => false
      # KKL
      t.string :kkl, :null => false, :limit => 1
    end
  end

  def self.down
    drop_table :KKLVerlauf
  end
end
