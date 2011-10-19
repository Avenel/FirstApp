class AddDeviseToOZBPerson < ActiveRecord::Migration
  def self.up
  
   change_table(:OZBPerson) do |t|
		t.remove :passwort, :pwAendDatum
		t.database_authenticatable :null => false
		#t.confirmable
		#t.recoverable
		t.rememberable
		t.trackable
		# t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
   end
		
		add_index :OZBPerson, :id,										:unique => true
		add_index :OZBPerson, :confirmation_token,		:unique => true
    add_index :OZBPerson, :reset_password_token,	:unique => true
  
	end

  def self.down
			
  end
end
