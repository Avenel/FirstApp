class OZBPersonController < ApplicationController

  def index
		@OZBPersonen = OZBPerson.paginate(:page => params[:page], :per_page => 1)
  end

  def new
  end
	
	def save
    begin
      @kontoklasse = Kontenklasse.find(params[:kkl])
      @kontoklasse.prozent = params[:prozent]
      @kontoklasse.kklAbDatum = Date.parse(params[:kklAbDatum])
      @kontoklasse.save!
    rescue
			#Person erstellen
			@new_Person = Person.create ( :rolle => params[:rolle], :name => params[:name], :vorname => params[:vorname], :geburtsdatum => params[:gebDatum],
																		:plz => params[:plz], :ort => params[:ort] )
			
			#Login erstellen
			@new_OZBPerson = OZBPerson.create( :ueberPnr => @new_Person.pnr, :email => params[:email], :password => "ozb-2000" )
			
			#Kontodaten hinzufuegen
			@new_Bankverbindung = Bankverbindung.create ( :pnr => @new_Person.pnr, :bankKtoNr => params[:kontonr], :blz => params[:blz],
																										:bankName => params[:bankname] ) 
			
			#Datensaetze speichern
			@new_Person.save!
			@new_OZBPerson.save!
			@new_Bankverbindung.save!
			
			#Telefon hinzufuegen
			if params[:telefon].length > 0
				@new_Telefon = Telefon.create( :pnr => @new_Person.pnr, :telefonNr => params[:telefon], :telefonTyp => "Tel" )
				@new_Telefon.save!
			end
			
			#Fax hinzufuegen
			if params[:fax].length > 0
				@new_Fax = Telefon.create( :pnr => @new_Person.pnr, :telefonNr => params[:telefon], :telefonTyp => "Fax" )
				@new_Fax.save!
			end				
    end 
	redirect_to :action => "index"
  end
end
