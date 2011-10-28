class ReportsController < ApplicationController

  def ozbKonten
    @ozbKonten = OZBKonto.paginate(:per_page => 5, :page => params[:page])  
  end
  
  def rahmenvertraege
  end
  
  def meldungen
  end
  
  def adressen
    @personen = Person.paginate(:per_page => 5, :page => params[:page])  
  end

end
