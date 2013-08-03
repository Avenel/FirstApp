
class Teilnahme < ActiveRecord::Base
	self.table_name = "Teilnahme"
  self.primary_keys = :Pnr, :Vnr

  attr_accessible :Pnr, :Vnr, :TeilnArt, :SachPnr

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Vnr, :presence => true, :format => { :with => /^([0-9]+)$/i }

  # enum TeilnArt
	AVAILABLE_PARTICIPATIONS = %W(a e u l) #a = anwesend, e = entschuldigt, u = unentschuldigt, l = eingeladen 
	validates :TeilnArt, :presence => true, :inclusion => { :in => AVAILABLE_PARTICIPATIONS, :message => "%{value} is not a valid participation (a, e, u, l)" }

  # Relations
  belongs_to :Veranstaltung, :foreign_key => :Vnr, :dependent => :destroy
end
