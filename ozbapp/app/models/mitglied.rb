class Mitglied < ActiveRecord::Base
  self.table_name = "Mitglied"
  self.primary_keys = :Mnr, :GueltigVon
  
  alias_attribute :mnr, :Mnr
  alias_attribute :rvDatum, :RVDatum
  alias_attribute :sachPnr, :SachPnr
  
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :RVDatum, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr       => 'Mitglied-Nr.',
    :RVDatum   => 'RVDatum'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }


  # Relations
  belongs_to :OZBPerson, :foreign_key => :Mnr

  @@copy = nil
  
  before_save do 
    unless(self.GueltigBis || self.GueltigVon)
        self.GueltigVon = Time.now      
        self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")      
    end
  end

  before_update do      
    if(self.Mnr)
      if(self.GueltigBis > "9999-01-01 00:00:00")
          @@copy            = Mitglied.get(self.Mnr)
          @@copy            = @@copy.dup
          @@copy.Mnr        = self.Mnr
          @@copy.GueltigVon = self.GueltigVon
          @@copy.GueltigBis = Time.now      
          
          self.GueltigVon   = Time.now      
          self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")      
      end
    end
  end

   after_update do
      if !@@copy.nil?
        @@copy.save(:validation => false)
        @@copy = nil
      end
   end

  # Returns nil if at the given time no person object was valid
  def Mitglied.get(pnr, date = Time.now)
    Mitglied.where(:Mnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
  end

end
