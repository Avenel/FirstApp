class Teilnahme < ActiveRecord::Base
  
	self.table_name = "Teilnahme"
  self.primary_keys = :Pnr, :Vnr

  # attributes
  attr_accessible :Pnr, :Vnr, :TeilnArt, :SachPnr

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Vnr, :presence => true, :format => { :with => /^([0-9]+)$/i }

  # enum TeilnArt
	AVAILABLE_PARTICIPATIONS = %W(a e u l) #a = anwesend, e = entschuldigt, u = unentschuldigt, l = eingeladen 
	validates :TeilnArt, :presence => true, :inclusion => { :in => AVAILABLE_PARTICIPATIONS, :message => "%{value} is not a valid participation (a, e, u, l)" }

  # Associations
  belongs_to :Veranstaltung, 
    :primary_key => :Vnr,
    :foreign_key => :Vnr

  belongs_to :Person,
    :primary_key => :Pnr,
    :foreign_key => :Pnr

end
