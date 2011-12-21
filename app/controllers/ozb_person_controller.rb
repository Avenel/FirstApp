# encoding: UTF-8
class OZBPersonController < ApplicationController

  @@Rollen = Hash["Mitglied", "M", "Foerdermitglied", "F", "Partner", "P", "Gesellschafter", "G", "Student", "S"]
  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Rollen2 = Hash["M", "Mitglied", "F", "Foerdermitglied", "P", "Partner", "G", "Gesellschafter", "S", "Student"]

  def index
    if current_OZBPerson.canEditA then
      @OZBPersonen = OZBPerson.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end
  
  def edit
    if current_OZBPerson.canEditB then
      searchOZBPerson()
      @OZBPerson = OZBPerson.find(params[:id])
      @Person = Person.find(@OZBPerson.ueberPnr)
      @Rollen2 = @@Rollen2
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
        @PartnerPerson = Person.find(@Partner.mnrO)
      when "G"
        @Gesellschafter = Gesellschafter.find(@OZBPerson.mnr)
      when "S"
        @Student = Student.find(@OZBPerson.mnr)
      end
    else
      redirect_to "/"
    end
  end
  
  def update
    if current_OZBPerson.canEditB then
      @OZBPerson = OZBPerson.find(params[:mnr])
      @Person = Person.find(@OZBPerson.ueberPnr)
      @Telefon = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Tel"})
      @Fax = Telefon.find(:all, :conditions => {:pnr => @Person.pnr, :telefonTyp => "Fax"})
      @Person.name = params[:name]
      @Person.vorname = params[:vorname]
      @OZBPerson.email = params[:email]
      if params[:password] != "********"
        @OZBPerson.password = params[:password]
      end
      @Person.geburtsdatum = Date.parse(params[:gebDatum])
      @Person.strasse = params[:strasse]
      @Person.hausnr = params[:hausnr]
      @Person.plz = params[:plz]
      @Person.ort = params[:ort]
      @Person.antragsdatum = params[:antragsdatum]
      @Person.aufnahmedatum = params[:aufnahmedatum]
      
      case @Person.rolle
      when "M"
        @Mitglied = Mitglied.find(@OZBPerson.mnr)
        @Mitglied.rvDatum = params[:rvDatum]
        @Mitglied.save!
      when "F"
        @Foerdermitglied = Foerdermitglied.find(@Person.pnr)
        @Foerdermitglied.region = params[:region]
        @Foerdermitglied.foerderbeitrag = params[:foerderbeitrag]
        @Foerdermitglied.save!
      when "P"
        @Partner = Partner.find(@OZBPerson.mnr)
        @Partner.mnrO = params[:partner]
        @Partner.berechtigung = params[:berechtigung]
        @Partner.save!
      when "G"
        @Gesellschafter = Gesellschafter.find(@OZBPerson.mnr)
        @Gesellschafter.faSteuerNr = params[:faSteuerNr]
        @Gesellschafter.faLfdNr = params[:faLfdNr]
        @Gesellschafter.wohnsitzFinanzamt = params[:wohnsitzFinanzamt]
        @Gesellschafter.notarPnr = params[:notarPnr]
        @Gesellschafter.beurkDatum = params[:beurkDatum]
        @Gesellschafter.save!
      when "S"
        @Student = Student.find(@OZBPerson.mnr)
        @Student.ausbildBez = params[:ausbildBez]
        @Student.institutName = params[:institutName]
        @Student.studienort = params[:studienort]
        @Student.studienbeginn = params[:studienbeginn]
        @Student.studienende = params[:studienende]
        @Student.abschluss = params[:abschluss]
        @Student.save!
      end
      
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

      redirect_to :action => "index"
    else
      redirect_to "/"
    end
  end

  def new
    if current_OZBPerson.canEditB then
      searchOZBPerson()
      @Rollen = @@Rollen
      @new_Person = Person.new
      @new_OZBPerson = OZBPerson.new
      @new_Student = Student.new
      @new_Foerdermitglied = Foerdermitglied.new
      @new_Gesellschafter = Gesellschafter.new
      @new_Partner = Partner.new
      @new_Mitglied = Mitglied.new     
      
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
  
  def create
    @errors = Array.new
    
    @new_Person = Person.new
    @new_OZBPerson = OZBPerson.new
    @new_Student = Student.new
    @new_Foerdermitglied = Foerdermitglied.new
    @new_Gesellschafter = Gesellschafter.new
    @new_Partner = Partner.new
    @new_Mitglied = Mitglied.new     
    
    #Person erstellen
    @new_Person = Person.create( :rolle => params[:rolle], :name => params[:name], :vorname => params[:vorname], :geburtsdatum => params[:gebDatum],
                                  :strasse => params[:strasse], :hausnr => params[:hausnr], :plz => params[:plz], :ort => params[:ort], :antragsdatum => params[:antragsdatum],
                                  :aufnahmedatum => params[:aufnahmedatum] )
  
    #Fehler aufgetreten?
    if !@new_Person.errors.empty? then
      @errors.push(@new_Person.errors)
    end
    
    #Login erstellen
    @new_OZBPerson = OZBPerson.create( :ueberPnr => @new_Person.pnr, :email => params[:email], :password => params[:passwort] )
  
    #Fehler aufgetreten?
    if !@new_OZBPerson.errors.empty? then
      @errors.push(@new_OZBPerson.errors)
    end
        
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
      #Fehler aufgetreten?
      if !@new_Gesellschafter.errors.empty? then
        @errors.push(@new_Gesellschafter.errors)
      end
    when "S"
      @new_Student = Student.create( :mnr => @new_OZBPerson.mnr,
                                     :ausbildBez => params[:ausbildBez],
                                     :institutName => params[:institutName],
                                     :studienort => params[:studienort],
                                     :studienbeginn => params[:studienbeginn],
                                     :studienende => params[:studienende],
                                     :abschluss => params[:abschluss] )
      #Fehler aufgetreten?
      if !@new_Student.errors.empty? then
        @errors.push(@new_Student.errors)
      end
    when "M"
      @new_Mitglied = Mitglied.create( :mnr => @new_OZBPerson.mnr,
                                       :rvDatum => params[:rvDatum] )
      #Fehler aufgetreten?
      if !@new_Mitglied.errors.empty? then
        @errors.push(@new_Mitglied.errors)
      end
    when "P"
      @new_Partner = Partner.create( :mnr => @new_OZBPerson.mnr,
                                     :mnrO => params[:partner],
                                     :berechtigung => params[:berechtigung] )
      #Fehler aufgetreten?
      if !@new_Partner.errors.empty? then
        @errors.push(@new_Partner.errors)
      end
    when "F"
      @new_Foerdermitglied = Foerdermitglied.create( :pnr => @new_Person.pnr, 
                                                     :region => params[:region],
                                                     :foerderbeitrag => params[:foerderbeitrag] )
      #Fehler aufgetreten?
      if !@new_Foerdermitglied.errors.empty? then
        @errors.push(@new_Foerdermitglied.errors)
      end
    end
    if @errors.empty? then      
      #Datensaetze speichern
      @new_Person.save!
      @new_OZBPerson.save!
      
      case params[:rolle]
      when "G"
        @new_Gesellschafter.save!
      when "S"
        @new_Student.save!
      when "M"
        @new_Mitglied.save!
      when "P"
        @new_Partner.save!
      when "F"
        @new_Foerdermitglied.save!
      end      
      
      redirect_to :action => "index", :notice => "Person erfolgreich angelegt."
    else
      searchOZBPerson()
      @Rollen = @@Rollen      
      render "new"  
    end 
      
  end	
  
  def show
  end
  
end
