#!/bin/env ruby
# encoding: utf-8
class VerwaltungController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_user!
  authorize_resource :class => false, :only => [:newOZBPerson, :createOZBPerson, :listOZBPersonen, :detailsOZBPerson, :editPersonaldaten, :updatePersonaldaten, :editKontaktdaten, :updateKontaktdaten, :editRolle, :updateRolle, :editBerechtigungen, :createBerechtigung, :deleteBerechtigung]

  # Zugriff der Methoden aus der View. NU
  helper_method :sort_column, :sort_direction, :rollen_bezeichnung

  def index
    
  end
  
  @@Rollen2 = Hash["Mitglied", "M", "Fördermitglied", "F", "Partner", "P", "Gesellschafter", "G", "Student", "S"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Rollen = Hash["M", "Mitglied", "F", "Fördermitglied", "P", "Partner", "G", "Gesellschafter", "S", "Student"]


  def searchOZBPerson
    super
  end


### Mitglieder hinzufügen ###
  def newOZBPerson
    @DistinctPersonen    = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
    @Rollen              = @@Rollen2
    @Rollen2             = @@Rollen
    @new_Person          = Person.new
    @new_OZBPerson       = OZBPerson.new
    @new_Student         = Student.new
    @new_Foerdermitglied = Foerdermitglied.new
    @new_Gesellschafter  = Gesellschafter.new
    @new_Partner         = Partner.new
    @new_Mitglied        = Mitglied.new     
    @new_Telefon         = Telefon.new
    @new_Fax             = Telefon.new
    @new_Mobil           = Telefon.new
    @new_Adresse         = Adresse.new   
    @new_Pnr             = Person.last.Pnr + 1
  end

  def createOZBPerson
    @errors = Array.new                                       

    begin    
    #Beginne Transaktion
    ActiveRecord::Base.transaction do
       ## Person erstellen und validieren
        @new_Person = Person.new(
            :Pnr          => params[:Pnr], 
            :Rolle        => params[:rolle], 
            :Name         => params[:name], 
            :Vorname      => params[:vorname], 
            :Geburtsdatum => params[:gebDatum], 
            :EMail        => params[:email],
            :SachPnr      => current_user.Mnr 
        )

        #Fehler aufgetreten?
        if !@new_Person.valid? then
          @errors.push(@new_Person.errors)
        end

        logger.debug("new Person valid!")

        # Achtung: UberPnr erweitern: Definition + Maske
        logger.debug(current_user.Mnr)

        @new_OZBPerson = OZBPerson.new(
            :Mnr            => @new_Person.Pnr, 
            :UeberPnr       => current_user.Mnr, 
            #:email          => params[:email], 
            #:password       => params[:passwort], 
            :Antragsdatum   => params[:antragsdatum],
            :Aufnahmedatum  => params[:aufnahmedatum],
            :Austrittsdatum => params[:austrittsdatum],
            #:PWAendDatum    => Date.today, #NU
            :SachPnr        => current_user.Mnr
        )

        logger.debug("new OZBPerson")

        #Fehler aufgetreten?
        if !@new_OZBPerson.valid? then
          @errors.push(@new_OZBPerson.errors)
        end

        logger.debug("new OZBPerson valid")

        # Login erstellen und validieren
        @new_user = User.new(
            :id => @new_OZBPerson.Mnr,
            :email => @new_Person.EMail,
            :password => params[:passwort],
            :password_confirmation => params[:passwort]
        )

        #Fehler aufgetreten?
        if !@new_user.valid? then
          @errors.push(@new_user.errors)
        end

        logger.debug("new user valid!")
               
       ## Adresse erstellen und validieren
        @new_Adresse = Adresse.new( 
            :Pnr     => @new_Person.Pnr, 
            :Strasse => params[:strasse], 
            :Nr      => params[:hausnr], 
            :PLZ     => params[:plz], 
            :Ort     => params[:ort],
            :Vermerk => params[:vermerk],
            :SachPnr => current_user.Mnr
        )

        if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 then
          #Fehler aufgetreten?
          if !@new_Adresse.valid? then
            @errors.push(@new_Adresse.errors)
          end
        end

       ## Telefon erstellen und validieren
        @LfdNr = 1
        @new_Telefon = Telefon.new( 
            :Pnr        => @new_Person.Pnr, 
            :LfdNr      => @LfdNr, 
            :TelefonNr  => params[:telefon], 
            :TelefonTyp => "tel" 
        )

        if params[:telefon].length > 0 then
          @LfdNr = @LfdNr + 1
          #Fehler aufgetreten?
          if !@new_Telefon.valid? then
            @errors.push(@new_Telefon.errors)
          end
        end

       ## Mobil erstellen und validieren
        @new_Mobil = Telefon.new( 
            :Pnr        => @new_Person.Pnr, 
            :LfdNr      => @LfdNr, 
            :TelefonNr  => params[:mobil], 
            :TelefonTyp => "mob" 
        )

        if params[:mobil].length > 0 then
          @LfdNr = @LfdNr + 1
          #Fehler aufgetreten?
          if !@new_Mobil.valid? then
            @errors.push(@new_Mobil.errors)
          end
        end

       ## Fax erstellen und validieren
        @new_Fax = Telefon.new( 
            :Pnr        => @new_Person.Pnr, 
            :LfdNr      => @LfdNr, 
            :TelefonNr  => params[:fax], 
            :TelefonTyp => "fax" 
        )

        if params[:fax].length > 0 then
          #Fehler aufgetreten?
          if !@new_Fax.valid? then
            @errors.push(@new_Fax.errors)
          end
        end 

        logger.debug("here")

       ## Rolle erstellen und validieren       
        @new_Gesellschafter = Gesellschafter.new( 
            :Mnr               => @new_OZBPerson.Mnr, 
            :FASteuerNr        => params[:faSteuerNr],
            :FALfdNr           => params[:faLfdNr],
            :FAIdNr            => params[:faIdNr],
            :Wohnsitzfinanzamt => params[:wohnsitzFinanzamt], 
            :NotarPnr          => params[:notarPnr], 
            :BeurkDatum        => params[:beurkDatum],
            :SachPnr           => current_user.Mnr  
        )              

        @new_Student = Student.new( 
            :Mnr           => @new_OZBPerson.Mnr,
            :AusbildBez    => params[:ausbildBez],
            :InstitutName  => params[:institutName],
            :Studienort    => params[:studienort],
            :Studienbeginn => params[:studienbeginn],
            :Studienende   => params[:studienende],
            :Abschluss     => params[:abschluss],
            :SachPnr       => current_user.Mnr 
        )

        @new_Mitglied = Mitglied.new( 
            :Mnr     => @new_OZBPerson.Mnr, 
            :RVDatum => params[:rvDatum],
            :SachPnr => current_user.Mnr 
        )

        @new_Partner = Partner.new( 
            :Mnr          => @new_OZBPerson.Mnr, 
            :Pnr_P         => params[:partner], 
            :Berechtigung => params[:berechtigung], 
            :SachPnr      => current_user.Mnr 
        )

        @new_Foerdermitglied = Foerdermitglied.new( 
            :Pnr            => @new_Person.Pnr, 
            :Region         => params[:region], 
            :Foerderbeitrag => params[:foerderbeitrag], 
            :SachPnr        => current_user.Mnr 
        )    

        logger.debug("here2")

        error = false
        case params[:rolle]
        when "G"
          #Fehler aufgetreten?
          if !@new_Gesellschafter.valid? then
            @errors.push(@new_Gesellschafter.errors)
            error = true
          end
        when "S"
          #Fehler aufgetreten?
          if !@new_Student.valid? then
            @errors.push(@new_Student.errors)
            error = true
          end
        when "M"
          #Fehler aufgetreten?
          if !@new_Mitglied.valid? then
            @errors.push(@new_Mitglied.errors)
            error = true
          end
        when "P"
          #Fehler aufgetreten?
          if !@new_Partner.valid? then
            @errors.push(@new_Partner.errors)
            error = true
          end
        when "F"
          #Fehler aufgetreten?
          if !@new_Foerdermitglied.valid? then
            @errors.push(@new_Foerdermitglied.errors)
            error = true
          end
        end

        if !error       
          logger.debug("her3")
          ## Person speichern
          if @new_Person.save!

            ## OZBPerson speichern
            if @new_OZBPerson.save!
              logger.debug("her4")

              ## User speichern
              @new_user.save!
              logger.debug("her5")
            end
            
          end

          logger.debug("her6")

         ## Rolle speichern        
          case params[:rolle]
          when "G"
            #Datensatz speichern
            @new_Gesellschafter.save!
          when "S"
            #Datensatz speichern
            @new_Student.save!
          when "M"
            #Datensatz speichern
            @new_Mitglied.save!
          when "P"
            #Datensatz speichern
            @new_Partner.save!
          when "F"
            #Datensatz speichern
            @new_Foerdermitglied.save!
          end

         ## Adresse speichern
          if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 || params[:vermerk].length > 0 then
            @new_Adresse.save!          
          end
          
         ## Telefon speichern
          if params[:telefon].length > 0 then
            @new_Telefon.SachPnr = current_user.Mnr
            @new_Telefon.save!          
          end
          
         ## Mobil speichern
          if params[:mobil].length > 0 then   
            @new_Mobil.SachPnr = current_user.Mnr       
            @new_Mobil.save!
          end
          
         ## Fax speichern speichern
          if params[:fax].length > 0 then
            @new_Fax.SachPnr = current_user.Mnr
            @new_Fax.save!          
          end
         
          # Weiterleitung bei erfolgreicher Speicherung  
          flash[:notice] = "Person wurde erfolgreich hinzugefügt."
          redirect_to :action => "listOZBPersonen"   
        else
          render "newOZBPerson"
        end     
    end
    # Bei Fehlern Daten retten
    rescue
      @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
      @Rollen = @@Rollen2
      @Rollen2 = @@Rollen 
      puts "123"
      puts @errors
      render "newOZBPerson"
    end   
  end 


### Alle Mitglieder anzeigen ###
  def listOZBPersonen
    @OZBPersonen = OZBPerson.joins(:Person).order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 25)
  end


### Details einer Person anzeigen ###
  def detailsOZBPerson
    @OZBPerson = OZBPerson.find(params[:Mnr])
    @Person    = Person.get(@OZBPerson.Mnr)
    @Adresse   = Adresse.get(@Person.Pnr)
    
    @Telefon   = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "tel"})
    @Fax       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "fax"})
    @Mobil     = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "mob"})

    @Tel       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr}, :order => "LfdNr ASC")

    @Rollen    = @@Rollen  
    @Rollen2   = @@Rollen2
    case @Person.Rolle
    when "M"
      @Mitglied = Mitglied.get(@OZBPerson.Mnr)
    when "F"
      @Foerdermitglied = Foerdermitglied.get(@Person.Pnr)
    when "P"
      @Partner = Partner.get(@OZBPerson.Mnr)
      #if !@Partner.nil? then
      #  @PartnerPerson = Person.get(@Partner.Pnr_P)
      #end
    when "G"
      @Gesellschafter = Gesellschafter.get(@OZBPerson.Mnr)
    when "S"
      @Student = Student.get(@OZBPerson.Mnr)
    end    
  end


### Mitglieder bearbeiten: Personaldaten ###
  def editPersonaldaten
    @OZBPerson = OZBPerson.find(params[:Mnr])
    @Person    = Person.get(@OZBPerson.Mnr)
    @Fullname  = @Person.Name + ", " + @Person.Vorname
  end
  
  def updatePersonaldaten
    @errors = Array.new                                       
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson                = OZBPerson.find(params[:Mnr])
        @Person                   = Person.get(@OZBPerson.Mnr)
        @Fullname                 = @Person.Name + ", " + @Person.Vorname
        
        @Person.Name              = params[:name]
        @Person.Vorname           = params[:vorname]
        @Person.Geburtsdatum      = params[:gebDatum]
        @Person.SachPnr           = current_user.Mnr
        
        @OZBPerson.Antragsdatum   = params[:antragsdatum]
        @OZBPerson.Aufnahmedatum  = params[:aufnahmedatum]    
        @OZBPerson.Austrittsdatum = params[:austrittsdatum]
        @OZBPerson.SachPnr        = current_user.Mnr
           
       #Fehler aufgetreten?
        if !@Person.valid? then
          @errors.push(@Person.errors)
        end
        
       #Fehler aufgetreten?
        if !@OZBPerson.valid? then
          @errors.push(@OZBPerson.errors)
        end    

       # Datensaetze speichern 
        @Person.save!
        @OZBPerson.save!
         
       # Weiterleiten  
        flash[:notice] = "Personaldaten wurden erfolgreich aktuallisiert."
        redirect_to :action => "editPersonaldaten" 
        # render "editPersonaldaten"
      end
    # Bei Fehlern Daten reten
    rescue
      render "editPersonaldaten"
    end       
  end


### Mitglieder bearbeiten: Kontaktdaten ###
  def editKontaktdaten
    @OZBPerson = OZBPerson.find(params[:Mnr])
    @Person    = Person.get(@OZBPerson.Mnr)
    @Fullname  = @Person.Name + ", " + @Person.Vorname
    @Adresse   = Adresse.get(@Person.Pnr)
    @Telefon   = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "tel"})
    @Fax       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "fax"})
    @Mobil     = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "mob"})  
  end

  def updateKontaktdaten
    @errors = Array.new                                       
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson      = OZBPerson.find(params[:Mnr])
        @Person         = Person.get(@OZBPerson.Mnr)
        @Fullname       = @Person.Name + ", " + @Person.Vorname

       # Adresse         
        @Adresse = Adresse.get(@Person.Pnr)
        if @Adresse != nil then         
          # update
          @Adresse.Strasse = params[:strasse]
          @Adresse.Nr      = params[:hausnr]
          @Adresse.PLZ     = params[:plz]
          @Adresse.Ort     = params[:ort]
          @Adresse.Vermerk = params[:vermerk]
          @Adresse.SachPnr = current_user.Mnr
        else
          if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 || params[:vermerk] then
            # create
            @Adresse = Adresse.new( 
              :Pnr     => @Person.Pnr, 
              :Strasse => params[:strasse], 
              :Nr      => params[:hausnr], 
              :PLZ     => params[:plz], 
              :Ort     => params[:ort],
              :Vermerk => params[:vermerk],
              :SachPnr => current_user.Mnr
            )
          end
        end

       # Telefon, Mobil, Fax
        @last_LfdNr = Telefon.where("Pnr = ?", @Person.Pnr).order("LfdNr DESC").first
        if @last_LfdNr then
          @LfdNr = Telefon.where("Pnr = ?", @Person.Pnr).order("LfdNr DESC").first.LfdNr + 1
        else   
          @LfdNr = 1
        end

        @Telefon = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "tel"})
        if @Telefon[0] != nil && params[:telefon].empty?
            @Telefon[0].destroy
        elsif @Telefon[0] != nil && !params[:telefon].empty? then
            # update
            @Telefon[0].TelefonNr = params[:telefon]
        elsif params[:telefon].length > 0 then
            # create
            @Telefon[0] = Telefon.new( 
              :Pnr        => @Person.Pnr, 
              :LfdNr      => @LfdNr, 
              :TelefonNr  => params[:telefon], 
              :TelefonTyp => "tel" 
            )
            @LfdNr = @LfdNr + 1
        end

        @Mobil = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "mob"})
        if @Mobil[0] != nil && params[:mobil].empty?
            @Mobil[0].destroy
        elsif @Mobil[0] != nil && !params[:mobil].empty? then
            # update
            @Mobil[0].TelefonNr = params[:mobil]
        elsif params[:mobil].length > 0 then
            # create
            @Mobil[0] = Telefon.new( 
                :Pnr        => @Person.Pnr, 
                :LfdNr      => @LfdNr, 
                :TelefonNr  => params[:mobil], 
                :TelefonTyp => "mob" 
            )
            @LfdNr = @LfdNr + 1
        end
                
        @Fax = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "fax"})
        if @Fax[0] != nil && params[:fax].empty?
            @Fax[0].destroy
        elsif @Fax[0] != nil && !params[:fax].empty? then
            # update
            @Fax[0].TelefonNr = params[:fax]
        elsif params[:fax].length > 0 then
            # create
            @Fax[0] = Telefon.new( 
                :Pnr        => @Person.Pnr, 
                :LfdNr      => @LfdNr, 
                :TelefonNr  => params[:fax], 
                :TelefonTyp => "fax" 
            )
        end
        
 
       # EMail
        # @OZBPerson.email = params[:email]
        @OZBPerson.SachPnr = current_user.Mnr
        
       # EMail bei OZBPerson speichern         
        #Fehler aufgetreten?
        if !@OZBPerson.valid? then
          @errors.push(@OZBPerson.errors)
        end    
        @OZBPerson.save!

         
       if @Person.EMail != params[:email] then
        @Person.EMail   = params[:email]
        @Person.SachPnr = current_user.Mnr
       # EMail bei Person speichern       
        #Fehler aufgetreten?
        if !@Person.valid? then
          @errors.push(@Person.errors)
        end
        @Person.save!        
       end
               
        
       # Adresse speichern
        if @Adresse != nil then
        #if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 then
          #Fehler aufgetreten?
          if !@Adresse.valid? then
             @errors.push(@Adresse.errors)
          end
          #Datensatz speichern
          @Adresse.save!
        end

          # Telefon, Mobil, Fax speichern
        if @Telefon[0] != nil && !params[:telefon].empty? then
        #if params[:telefon].length > 0 then
          @Telefon[0].SachPnr = current_user.Mnr
          #Fehler aufgetreten?
          if !@Telefon[0].valid? then
            @errors.push(@Telefon[0].errors)
          end
          #Datensatz speichern
          @Telefon[0].save!
        end

        if @Mobil[0] != nil && !params[:mobil].empty? then
        #if params[:mobil].length > 0 then
          @Mobil[0].SachPnr = current_user.Mnr
          #Fehler aufgetreten?        
          if !@Mobil[0].valid? then
            @errors.push(@Mobil[0].errors)
          end
          #Datensatz speichern
          @Mobil[0].save!
        end

        if @Fax[0] != nil && !params[:fax].empty? then
        #if params[:fax].length > 0 then          
          @Fax[0].SachPnr = current_user.Mnr
          #Fehler aufgetreten?
          if !@Fax[0].valid? then
            @errors.push(@Fax[0].errors)
          end
          #Datensatz speichern
          @Fax[0].save!
        end
   
       # Weiterleiten
        flash[:notice] = "Kontaktdaten wurden erfolgreich aktuallisiert."
        # render "editKontaktdaten"
        redirect_to :action => "editKontaktdaten" 
      end
    # Bei Fehlern Daten reten
    rescue
      render "editKontaktdaten"
    end       
  end



### Mitglieder bearbeiten: Rolle ###
  def editRolle
    @OZBPerson        = OZBPerson.find(params[:Mnr])
    @Person           = Person.get(@OZBPerson.Mnr)
    
    @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
    @Rollen           = @@Rollen2
    @Rollen2          = @@Rollen
    
    @Student          = Student.new
    @Foerdermitglied  = Foerdermitglied.new
    @Gesellschafter   = Gesellschafter.new
    @Partner          = Partner.new
    @Mitglied         = Mitglied.new    
    
    case @Person.Rolle
    when "M"
      @Mitglied = Mitglied.get(@OZBPerson.Mnr)
    when "F"
      @Foerdermitglied = Foerdermitglied.get(@Person.Pnr)
    when "P"
      @Partner = Partner.get(@OZBPerson.Mnr)
      #if !@Partner.nil? then
      #  @PartnerPerson = Person.get(@Partner.Pnr_P)
      #else
      #  @Partner = Partner.new(:Mnr => @OZBPerson.Mnr, :Pnr_P => 0, :Berechtigung => "")          
      #end
    when "G"
      @Gesellschafter = Gesellschafter.get(@OZBPerson.Mnr)
    when "S"
      @Student = Student.get(@OZBPerson.Mnr)
    end

    @Berechtigungen = @@Berechtigungen2.sort
    @BerechtigungsName = @@Berechtigungen
    
    @Sonderberechtigung = Sonderberechtigung.find(:all, :conditions => {:Mnr => @OZBPerson.Mnr})
    @hasSonderberechtigung = false
    if !@Sonderberechtigung.first().nil? then
      @hasSonderberechtigung = true
    end

    @new_Sonderberechtigung = Sonderberechtigung.new        
  end

  def updateRolle
    @errors = Array.new                                       
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson       = OZBPerson.find(params[:Mnr])
        @Person          = Person.get(@OZBPerson.Mnr)
        @Fullname        = @Person.Name + ", " + @Person.Vorname    
        
        @Student         = Student.new
        @Foerdermitglied = Foerdermitglied.new
        @Gesellschafter  = Gesellschafter.new
        @Partner         = Partner.new
        @Mitglied        = Mitglied.new 
        
        @Rolle_to_update = @Person.Rolle.to_s
        
        ## Rolle bei Person aendern und validieren   
        @Person.Rolle = params[:rolle]
        #Fehler aufgetreten?
        if !@Person.valid? then
          @errors.push(@Person.errors)
        end
        
        if @Rolle_to_update == params[:rolle] then
          case params[:rolle]
          when "G"
            @Gesellschafter                   = Gesellschafter.get(@OZBPerson.Mnr)
            @Gesellschafter.FASteuerNr        = params[:faSteuerNr]
            @Gesellschafter.FAIdNr            = params[:faIdNr]
            @Gesellschafter.FALfdNr           = params[:faLfdNr]
            @Gesellschafter.Wohnsitzfinanzamt = params[:wohnsitzFinanzamt]
            @Gesellschafter.NotarPnr          = params[:notarPnr]
            @Gesellschafter.BeurkDatum        = params[:beurkDatum] 
            @Gesellschafter.SachPnr           = current_user.Mnr        
            #Fehler aufgetreten?
            if !@Gesellschafter.valid? then
              @errors.push(@Gesellschafter.errors)
            end
            #Datensatz speichern
            @Gesellschafter.save!
          when "S"
            @Student               = Student.get(@OZBPerson.Mnr) 
            @Student.AusbildBez    = params[:ausbildBez]
            @Student.InstitutName  = params[:institutName]
            @Student.Studienort    = params[:studienort]
            @Student.Studienbeginn = params[:studienbeginn]
            @Student.Studienende   = params[:studienende]
            @Student.Abschluss     = params[:abschluss]
            @Student.SachPnr       = current_user.Mnr           
            #Fehler aufgetreten?
            if !@Student.valid? then
              @errors.push(@Student.errors)
            end
            #Datensatz speichern
            @Student.save!
          when "M"
            @Mitglied         = Mitglied.get(@OZBPerson.Mnr)
            @Mitglied.RVDatum = params[:rvDatum]
            @Mitglied.SachPnr = current_user.Mnr           
            #Fehler aufgetreten?
            if !@Mitglied.valid? then
              @errors.push(@Mitglied.errors)
            end
            #Datensatz speichern
            @Mitglied.save!
          when "P"
            @Partner              = Partner.get(@OZBPerson.Mnr)
            @Partner.Pnr_P         = params[:partner]
            @Partner.Berechtigung = params[:berechtigung]
            @Partner.SachPnr      = current_user.Mnr
            #Fehler aufgetreten?
            if !@Partner.valid? then
              @errors.push(@Partner.errors)
            end
            #Datensatz speichern
            @Partner.save!
          when "F"
            @Foerdermitglied                = Foerdermitglied.get(@Person.Pnr)
            @Foerdermitglied.Region         = params[:region]
            @Foerdermitglied.Foerderbeitrag = params[:foerderbeitrag]
            @Foerdermitglied.SachPnr        = current_user.Mnr
            #Fehler aufgetreten?
            if !@Foerdermitglied.valid? then
              @errors.push(@Foerdermitglied.errors)
            end
            #Datensatz speichern
            @Foerdermitglied.save!
          end        
        else    
         # delete
          case @Rolle_to_update
          when "G"
            @Gesellschafter            = Gesellschafter.get(@OZBPerson.Mnr)
            @Gesellschafter.GueltigBis = Time.now
            @Gesellschafter.SachPnr    = current_user.Mnr
            @Gesellschafter.save!
          when "S"
            @Student            = Student.get(@OZBPerson.Mnr)
            @Student.GueltigBis = Time.now
            @Student.SachPnr    = current_user.Mnr
            @Student.save!
          when "M"
            #nu
            @Mitglied            = Mitglied.get(@OZBPerson.Mnr)
            @Mitglied.GueltigBis = Time.now
            @Mitglied.SachPnr    = current_user.Mnr
            @Mitglied.save!
          when "P"
            @Partner            = Partner.get(@OZBPerson.Mnr)
            @Partner.GueltigBis = Time.now
            @Partner.SachPnr    = current_user.Mnr
            @Partner.save!
          when "F"
            @Foerdermitglied            = Foerdermitglied.get(@Person.Pnr)
            @Foerdermitglied.GueltigBis = Time.now
            @Foerdermitglied.SachPnr    = current_user.Mnr
            @Foerdermitglied.save!
          end             
          
         # create
          case params[:rolle]
          when "G"
            @Gesellschafter = Gesellschafter.new( 
              :Mnr               => @OZBPerson.Mnr, 
              :FASteuerNr        => params[:faSteuerNr],
              :FAIdNr            => params[:faIdNr],
              :FALfdNr           => params[:faLfdNr],
              :Wohnsitzfinanzamt => params[:wohnsitzFinanzamt], 
              :NotarPnr          => params[:notarPnr], 
              :BeurkDatum        => params[:beurkDatum],
              :SachPnr           => current_user.Mnr 
            )

            #Fehler aufgetreten?
            if !@Gesellschafter.valid? then
              @errors.push(@Gesellschafter.errors)
            end
            #Datensatz speichern
            @Gesellschafter.save!
          when "S"
            @Student = Student.new( 
              :Mnr           => @OZBPerson.Mnr,
              :AusbildBez    => params[:ausbildBez],
              :InstitutName  => params[:institutName],
              :Studienort    => params[:studienort],
              :Studienbeginn => params[:studienbeginn],
              :Studienende   => params[:studienende],
              :Abschluss     => params[:abschluss],
              :SachPnr       => current_user.Mnr )      
            
            #Fehler aufgetreten?
            if !@Student.valid? then
              @errors.push(@Student.errors)
            end
            #Datensatz speichern
            @Student.save!
          when "M"
            @Mitglied = Mitglied.new( 
                :Mnr     => @OZBPerson.Mnr, 
                :RVDatum => params[:rvDatum],
                :SachPnr => current_user.Mnr 
            )   

            #Fehler aufgetreten?
            if !@Mitglied.valid? then
              @errors.push(@Mitglied.errors)
            end
            #Datensatz speichern
            @Mitglied.save!
          when "P"
            @Partner = Partner.new( 
                :Mnr          => @OZBPerson.Mnr, 
                :Pnr_P         => params[:partner], 
                :Berechtigung => params[:berechtigung], 
                :SachPnr      => current_user.Mnr 
            )
            #Fehler aufgetreten?
            if !@Partner.valid? then
              @errors.push(@Partner.errors)
            end
            #Datensatz speichern
            @Partner.save!
          when "F"
            @Foerdermitglied = Foerdermitglied.new( 
                :Pnr            => @Person.Pnr, 
                :Region         => params[:region], 
                :Foerderbeitrag => params[:foerderbeitrag], 
                :SachPnr        => current_user.Mnr 
            )
            #Fehler aufgetreten?
            if !@Foerdermitglied.valid? then
              @errors.push(@Foerdermitglied.errors)
            end
            #Datensatz speichern
            @Foerdermitglied.save!
          end  
              
        end
        
        #Datensatz speichern
        @Person.save!        
          
        # Weiterleiten
        flash[:notice] = "Rolle wurde erfolgreich aktuallisiert."
        redirect_to :action => "editRolle" 
        # render "editRolle"
      end
    # Bei Fehlern Daten reten
    rescue
      @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
      @Rollen           = @@Rollen2
      @Rollen2          = @@Rollen
      render "editRolle"
    end     
  end
  

### Mitglieder löschen ### 
  def deleteOZBPerson     
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson = OZBPerson.find(params[:Mnr])
        @Person = Person.get(@OZBPerson.Mnr)
        @Person.GueltigBis = Time.now
        @Person.save!

        @Student         = Student.new
        @Foerdermitglied = Foerdermitglied.new
        @Gesellschafter  = Gesellschafter.new
        @Partner         = Partner.new
        @Mitglied        = Mitglied.new 
        
        @Rolle = @Person.Rolle.to_s
        
        case @Rolle
          when "G"
          @Gesellschafter             = Gesellschafter.get(@OZBPerson.Mnr)
          @Gesellschafter.GueltigBis  = Time.now
          @Gesellschafter.SachPnr     = current_user.Mnr
          @Gesellschafter.save(:validation => false)
          when "S"
          @Student                    = Student.get(@OZBPerson.Mnr) 
          @Student.GueltigBis         = Time.now
          @Student.SachPnr            = current_user.Mnr
          @Student.save(:validation => false)
          when "M"
          @Mitglied                   = Mitglied.get(@OZBPerson.Mnr)
          @Mitglied.GueltigBis        = Time.now
          @Mitglied.SachPnr           = current_user.Mnr
          @Mitglied.save(:validation => false)
          when "P"
          @Partner                    = Partner.get(@OZBPerson.Mnr)
          @Partner.GueltigBis         = Time.now
          @Partner.SachPnr            = current_user.Mnr
          @Partner.save(:validation => false)
          when "F"
          @Foerdermitglied            = Foerdermitglied.get(@Person.Pnr)
          @Foerdermitglied.GueltigBis = Time.now
          @Foerdermitglied.SachPnr    = current_user.Mnr
          @Foerdermitglied.save(:validation => false)
        end         
        
        flash[:notice] = "Person wurde erfolgreich gelöscht."
        redirect_to :action => "listOZBPersonen"               
      end
    # Bei Fehlern Daten reten
    rescue
      redirect_to "/MeineKonten"
    end 
  end
 
  @@Berechtigungen2 = Hash[" Bitte auswählen", "", "Administrator", "IT", "Mitgliederverwaltung", "MV", "Finanzenverwaltung", "RW", "Projekteverwaltung", "ZE", "Öffentlichkeitsverwaltung", "OeA"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Berechtigungen = Hash["", "Nicht angegeben", "IT", "Administrator", "MV", "Mitgliederverwaltung", "RW", "Finanzenverwaltung", "ZE", "Projekteverwaltung", "OeA", "Öffentlichkeitsverwaltung"]
 
 
### Mitglieder Administrationsrechte geben ###
  def editBerechtigungen
    @OZBPerson = OZBPerson.find(params[:Mnr])
    @Person = Person.get(@OZBPerson.Mnr)
    
    @Geschaeftsprozesse = Geschaeftsprozess.all

    @Berechtigungen = @@Berechtigungen2.sort
    @BerechtigungsName = @@Berechtigungen
    
    @Sonderberechtigung = Sonderberechtigung.find(:all, :conditions => {:Mnr => @OZBPerson.Mnr})
    @hasSonderberechtigung = false
    if !@Sonderberechtigung.first().nil? then
      @hasSonderberechtigung = true
    end

    @new_Sonderberechtigung = Sonderberechtigung.new
  end

  def createBerechtigung
    @errors = Array.new                                       
    begin    
      #Beginne Transaktion
      ActiveRecord::Base.transaction do
        @sonderberechtigung = Sonderberechtigung.where("Mnr = ? AND EMail = ? AND Berechtigung = ?", params[:Mnr], params[:email], params[:berechtigung])

        if @sonderberechtigung.empty?
          @OZBPerson = OZBPerson.find(params[:Mnr])
          @Person    = Person.get(@OZBPerson.Mnr)

          ## Person erstellen und validieren
          @new_Sonderberechtigung = Sonderberechtigung.new(:Mnr => @OZBPerson.Mnr, :EMail => params[:email], :Berechtigung => params[:berechtigung])
          #Fehler aufgetreten?
          if !@new_Sonderberechtigung.valid? then
            @errors.push(@new_Sonderberechtigung.errors)
          end
          
          @new_Sonderberechtigung.save!
                    
          # Weiterleitung bei erfolgreicher Speicherung  
          flash[:notice] = "Berechtigung wurde erfolgreich hinzugefügt."
          session[:return_to] = request.referer
          redirect_to session[:return_to]       
        else
          flash[:error] = "Diese Berechtigung ist bereits vorhanden!"
          redirect_to session[:return_to]       
        end
      end
    # Bei Fehlern Daten reten
    rescue
      @Berechtigungen = @@Berechtigungen2.sort
      render "editBerechtigungen"
    end          
  end

  def deleteBerechtigung
    @Sonderberechtigung = Sonderberechtigung.find(params[:id])
    @Sonderberechtigung.delete
    
    # Weiterleitung bei erfolgreicher Speicherung  
    flash[:notice] = "Berechtigung wurde erfolgreich gelöscht."
    session[:return_to] = request.referer
      redirect_to session[:return_to]
  end

  def searchOZBPerson
    @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
  end


  private
  # Default Sortierspalte. NU
  def sort_column
    params[:sort] || "mnr"
  end

  # Default Sortierrichtung. NU
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Holt zu einer Rollenabkürzung den richtigen Namen. NU
  def rollen_bezeichnung (rolle)
    case rolle
      when "M"
        "Mitglied"
      when "F"
        "Fördermitglied"
      when "P"
        "Partner"
      when "G"
        "Gesellschafter"
      when "S"
        "Student"
    end
  end
end
