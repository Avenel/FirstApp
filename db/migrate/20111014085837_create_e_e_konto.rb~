class CreateEEKonto < ActiveRecord::Migration
  def self.up
    create_table(:EEKonto, :primary_key => :ktoNr) do |t|
      # Kontonummer PS, FS
      t.integer :ktoNr, :null => false, :uniqueness => true, :limit => 5
      # BankId FS
      t.integer :bankId, :limit => 3, :default => nil
      # Kreditlimit
      t.decimal :kreditlimit, :scale => 2, :precision => 5, :default => 0.00
    end
  end

  def self.down
    drop_table :ee_kontos
  end
end
