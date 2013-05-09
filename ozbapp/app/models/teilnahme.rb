
class Teilnahme < ActiveRecord::Base

  set_table_name "Teilnahme"

  attr_accessible :Pnr, :Vnr, :TeilnArt, :SachPnr

  set_primary_keys :Pnr, :Vnr

  
  
  


   
  belongs_to :Veranstaltung, :foreign_key => :Vnr, :dependent => :destroy
end
