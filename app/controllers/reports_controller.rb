class ReportsController < ApplicationController

  def ozbKonten
    @ozbKonten = OZBKonto.all
  end
  
  def buergschaften
    @buergschaften = Buergschaft.all
  end
  
  def rahmenvertraege
  end
  
  def meldungen
  end
  
  def adressen
    @personen = Person.all
  end

end
