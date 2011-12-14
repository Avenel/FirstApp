# encoding: UTF-8
class OZBPersonController < ApplicationController

  @@Rollen = {"Mitglied" => "M", "Foerdermitglied" => "F", "Partner" => "P", "Gesellschafter" => "G", "Student" => "S"}

  def index
    if current_OZBPerson.canEditA then
      @OZBPersonen = OZBPerson.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end
  
  def edit
    if current_OZBPerson.canEditB then
      @OZBPerson = OZBPerson.find(params[:id])
      @Person = Person.find(@OZBPerson.ueberPnr)
      @Rollen = @@Rollen
      #@Bankverbindungen = Bankverbindung.find(:all, :conditions => {:pnr => @Person.pnr})
      @Telefon = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Tel"})
      @Fax = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Fax"})
      case @Person.rolle
      when "M"
        @Mitglied = Mitglied.find(@OZBPerson.mnr)
      when "F"
        @Foerdermitglied = Foerdermitglied.find(@Person.pnr)
      when "P"
        @Partner = Partner.find(@OZBPerson.mnr)
      when "G"
        @Gesellschafter = Gesellschafter.find(@OZBPerson.mnr)
      when "S"
        @Student = Student.find(@OZBPerson.mnr)
      end
    else
      redirect_to "/"
    end
  end

  def new
    if current_OZBPerson.canEditB then
      searchOZBPerson()
      @Rollen = @@Rollen
    else
      redirect_to "/"
    end
  end

  def searchOZBPerson
    if current_OZBPerson.canEditB then
      super
    else
      redirect_to "/"
    end
  end
  
	def save
    if current_OZBPerson.canEditB then
      begin
        @OZBPerson = OZBPerson.find(params[:mnr])
        @Person = Person.find(@OZBPerson.ueberPnr)
        @Telefon = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Tel"})
        @Fax = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Fax"})
        @Person.rolle = params[:rolle]
        @Person.name = params[:name]
        @Person.vorname = params[:vorname]
        @Person.geburtsdatum = Date.parse(params[:gebDatum])
        @OZBPerson.email = params[:email]
        if params[:password] != ""
          @OZBPerson.password = params[:password]
        end
        @Person.strasse = params[:strasse]
        @Person.plz = params[:plz]
        @Person.ort = params[:ort]
        begin
          @Telefon[0].telefonNr = params[:telefon]
          @Telefon.save!
        rescue
          #Telefon hinzufuegen
          if params[:telefon].length > 0
            @new_Telefon = Telefon.create( :pnr => @Person.pnr, :telefonNr => params[:telefon], :telefonTyp => "Tel" )
            @new_Telefon.save!
          end
        end      
        begin
          @Fax[0].telefonNr = params[:fax]
          @Fax.save!
        rescue
          #Fax hinzufuegen
          if params[:fax].length > 0
            @new_Fax = Telefon.create( :pnr => @Person.pnr, :telefonNr => params[:fax], :telefonTyp => "Fax" )
            @new_Fax.save!
          end
        end
        @OZBPerson.save!
        @Person.save!
      rescue

			  #Person erstellen
			  @new_Person = Person.create( :rolle => params[:rolle], :name => params[:name], :vorname => params[:vorname], :geburtsdatum => params[:gebDatum],
																		  :strasse => params[:strasse], :plz => params[:plz], :ort => params[:ort], :antragsdatum => params[:antragsdatum],
																		  :aufnahmedatum => params[:aufnahmedatum] )
			
			  #Login erstellen
			  @new_OZBPerson = OZBPerson.create( :ueberPnr => @new_Person.pnr, :email => params[:email], :password => "ozb-2000" )
			
			  #Kontodaten hinzufuegen
			  #@new_Bankverbindung = Bankverbindung.create ( :pnr => @new_Person.pnr, :bankKtoNr => params[:kontonr], :blz => params[:blz],
			  #																							:bankName => params[:bankname] ) 
			
			  #Datensaetze speichern
			  @new_Person.save!
			  @new_OZBPerson.save!
			  #@new_Bankverbindung.save!
			
			  #Telefon hinzufuegen
			  if params[:telefon].length > 0
				  @new_Telefon = Telefon.create( :pnr => @new_Person.pnr, :telefonNr => params[:telefon], :telefonTyp => "Tel" )
				  @new_Telefon.save!
			  end
			
			  #Fax hinzufuegen
			  if params[:fax].length > 0
				  @new_Fax = Telefon.create( :pnr => @new_Person.pnr, :telefonNr => params[:fax], :telefonTyp => "Fax" )
				  @new_Fax.save!
			  end				
			
			  case params[:rolle]
			  when "G"
			    @new_Gesellschafter = Gesellschafter.create( :mnr => @new_OZBPerson.mnr, 
			                                                 :faSteuerNr => params[:faSteuerNr],
			                                                 :faLfdNr => params[:faLfdNr],
                                                       :wohnsitzFinanzamt => params[:wohnsitzFinanzamt], 
                                                       :notarPnr => params[:notarPnr], 
                                                       :beurkDatum => params[:beurkDatum] )
          @new_Gesellschafter.save!
        when "S"
          @new_Student = Student.create( :mnr => @new_OZBPerson.mnr,
                                         :ausbildBez => params[:ausbildBez],
                                         :institutName => params[:institutName],
                                         :studienort => params[:studienort],
                                         :studienbeginn => params[:studienbeginn],
                                         :studienende => params[:studienende],
                                         :abschluss => params[:abschluss] )
          @new_Student.save!
        when "M"
          @new_Mitglied = Mitglied.create( :mnr => @new_OZBPerson.mnr,
                                           :rvDatum => params[:rvDatum] )
          @new_Mitglied.save!
        when "P"
          @new_Partner = Partner.create( :mnr => @new_OZBPerson.mnr,
                                         :mnrO => params[:partner],
                                         :berechtigung => params[:berechtigung] )
          @new_Partner.save!
        when "F"
          @new_Foerdermitglied = Foerdermitglied.create( :pnr => @new_Person.pnr, 
                                                         :region => params[:region],
                                                         :foerderbeitrag => params[:foerderbeitrag] )
          @new_Foerdermitglied.save!
        end
                                                     			
      end 
	    redirect_to :action => "index"
	  else
	    redirect_to "/"
	  end
  end
  
  def show
  end
  
end
