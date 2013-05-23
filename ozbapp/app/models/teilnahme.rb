
class Teilnahme < ActiveRecord::Base

  self.table_name = "Teilnahme"

  self.primary_keys = :Pnr, :Vnr

  attr_accessible :Pnr, :Vnr, :TeilnArt, :SachPnr

  belongs_to :Veranstaltung, :foreign_key => :Vnr, :dependent => :destroy
end
