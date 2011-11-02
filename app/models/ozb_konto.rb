class OZBKonto < ActiveRecord::Base

  set_table_name "OZBKonto"

  set_primary_key :ktoNr

  attr_accessible :ktoNr, :mnr, :ktoEinrDatum, :waehrung, :wSaldo, :pSaldo, :saldoDatum

  belongs_to :OZBPerson
    
  has_many :Buchung, :foreign_key => [:ktoNr], :dependent => :delete_all # Done, getestet
  has_many :KKLVerlauf, :foreign_key => [:ktoNr], :dependent => :delete_all # Done, getestet
  has_many :ZEKonto, :foreign_key => :ktoNr, :dependent => :delete_all # Done, getestet
  has_many :EEKonto, :foreign_key => :ktoNr, :dependent => :delete_all # Done, getestet
end
