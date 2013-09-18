# encoding: UTF-8
class OZBPersonController < ApplicationController  
  #protect_from_forgery
  before_filter :authenticate_user!
  
  @@sop_rollen = Hash["Alle Rollen", "", "Mitglied", "M", "Fördermitglied", "F", "Partner", "P", "Gesellschafter", "G", "Student", "S"]
  
  
  @@Rollen2 = Hash["Mitglied", "M", "Fördermitglied", "F", "Partner", "P", "Gesellschafter", "G", "Student", "S"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Rollen = Hash["M", "Mitglied", "F", "Fördermitglied", "P", "Partner", "G", "Gesellschafter", "S", "Student"]


### Details MeineDaten
  def detailsOZBPerson
      @OZBPerson = OZBPerson.find(current_user.Mnr)
      @Person    = Person.get(@OZBPerson.Mnr)
      @Adresse   = Adresse.get(@Person.Pnr)
      @Telefon   = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "tel"})
      @Fax       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "fax"})
      @Mobil     = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "mob"})

      @Tel       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr}, :order => "LfdNr ASC")

      @Rollen  = @@Rollen  
      @Rollen2 = @@Rollen2
      
      case @Person.Rolle
      when "M"
      @Mitglied        = Mitglied.get(@OZBPerson.Mnr)
      when "F"
      @Foerdermitglied = Foerdermitglied.get(@Person.Pnr)
      when "P"
      @Partner         = Partner.get(@OZBPerson.Mnr)
      @PartnerPerson   = Person.get(@Partner.Pnr_P)
      when "G"
      @Gesellschafter  = Gesellschafter.get(@OZBPerson.Mnr)
      when "S"
      @Student         = Student.get(@OZBPerson.Mnr)
      end   

  end

### Mitglieder bearbeiten: Personaldaten ###
  def editPersonaldaten
      if is_allowed(current_user, 3)
        @OZBPerson = OZBPerson.find(current_user.Mnr)
        @Person    = Person.get(@OZBPerson.Mnr)
      else
        redirect_to "/MeineKonten"
      end
  end
  
  def updatePersonaldaten
    @errors = Array.new                                       
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson                = OZBPerson.find(current_user.Mnr)
        @Person                   = Person.get(@OZBPerson.Mnr)
        
        @Person.Name              = params[:name]
        @Person.Vorname           = params[:vorname]
        @Person.Geburtsdatum      = params[:gebDatum]
        @Person.SachPnr           = current_user.Mnr
        
        @OZBPerson.Antragsdatum   = params[:antragsdatum]
        @OZBPerson.Aufnahmedatum  = params[:aufnahmedatum]    
        @OZBPerson.Austrittsdatum = params[:austrittsdatum]
        @OZBPerson.SachPnr        = current_user.Mnr
        
        flash[:notice] = "Validieren"

        begin 
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
        rescue Exception => e
          puts e.message
          flash[:notice] = e.message
        end
         
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
      @OZBPerson = OZBPerson.find(current_user.Mnr)
      @Person    = Person.get(@OZBPerson.Mnr)
      @Adresse   = @Person.Adresse #Adresse.get(@Person.Pnr)
      @Telefon   = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "tel"})
      @Fax       = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "fax"})
      @Mobil     = Telefon.find(:all, :conditions => {:Pnr => @Person.Pnr, :TelefonTyp => "mob"})
  end

  def updateKontaktdaten
    @errors = Array.new                                       
    puts ">>>> DEBUGS Begin Transaction"
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
        @OZBPerson = OZBPerson.find(current_user.Mnr)
        @Person    = Person.get(@OZBPerson.Mnr) 

       # Email
       # OZBPerson soll in zukunft keine email adresse mehr enthalten, da devise es ausgelagert wird -> login table 
        # @OZBPerson.email   = params[:email]
        @OZBPerson.SachPnr = current_user.Mnr
        @Person.EMail      = params[:email]
        @Person.SachPnr    = current_user.Mnr

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
          if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 || params[:vermerk].length then
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
        
        puts ">>>> DEBUGS save OZBPerson"
       # Email bei OZBPerson speichern         
        #Fehler aufgetreten?
        begin
          if !@OZBPerson.valid? then
            @errors.push(@OZBPerson.errors)
          end    
          @OZBPerson.save!
        rescue Exception => e
          puts ">>>> DEBUG <<<<<<"
          puts e.message
          puts e.backtrace.join("\n")
          @errors.push(e.message)
        end
         

        puts ">>>> DEBUGS save Person"
        # Email bei Person speichern       
        #Fehler aufgetreten?
        begin
          if !@Person.valid? then
            @errors.push(@Person.errors)
          end
          @Person.save!
        rescue Exception => e
          puts ">>>> DEBUG <<<<<<"
          puts e.message
          puts e.backtrace.join("\n")
          @errors.push(e.message)
        end
        
        puts ">>>> DEBUGS save Adresse"
       # Adresse speichern
        if @Adresse != nil then
        #if params[:strasse].length > 0 || params[:hausnr].length > 0 || params[:plz].length > 0 || params[:ort].length > 0 then
          #Fehler aufgetreten?
          if !@Adresse.valid? then
             @errors.push(@Adresse.errors)
          end
          #Datensatz speichern
          begin
            puts ">>>> DEBUG save! operation <<<<<<"
            puts @Adresse.inspect
            @Adresse.save!
          rescue Exception => e
            puts ">>>> DEBUG <<<<<<"
            puts e.message
            puts e.backtrace.join("\n")
            @errors.push(e.message)
          end
          puts ">>>> DEBUG save! END operation <<<<<<"
        end

       # Telefon, Mobil, Fax speichern
       puts ">>>> DEBUG save Telefon <<<<<<"
        if @Telefon[0] != nil && !params[:telefon].empty? then
          #Fehler aufgetreten?
          if !@Telefon[0].valid? then
            puts ">>>> DEBUGS error telefon"
            @errors.push(@Telefon[0].errors)
            puts ">>>> DEBUGS " + @errors.inspect
          end
          #Datensatz speichern
          puts ">>>> DEBUG save! operation <<<<<<"
          @Telefon[0].save!
        end

        puts ">>>> DEBUG save Mobil <<<<<<"
        if @Mobil[0] != nil && !params[:mobil].empty? then
        #if params[:mobil].length > 0 then
          #@Mobil[0].SachPnr = current_user.Mnr
          #Fehler aufgetreten?        
          if !@Mobil[0].valid? then
            puts ">>>> ERROR VAldiation save operation <<<<<<"
            puts @Mobil[0].errors
            @errors.push(@Mobil[0].errors)
          end
          #Datensatz speichern
          puts ">>>> DEBUG save operation <<<<<<"
          @Mobil[0].save!
        end

        puts ">>>> DEBUG save Fax <<<<<<"
        if @Fax[0] != nil && !params[:fax].empty? then
        #if params[:fax].length > 0 then          
          #@Fax[0].SachPnr = current_user.Mnr
          #Fehler aufgetreten?
          if !@Fax[0].valid? then
            @errors.push(@Fax[0].errors)
          end
          #Datensatz speichern
          @Fax[0].save!
        end
   
       # Weiterleiten
        flash[:notice] = "Kontaktdaten wurden erfolgreich aktuallisiert."
        redirect_to :action => "editKontaktdaten"      
        # render "editKontaktdaten"
      end
    # Bei Fehlern Daten reten
    rescue
      render "editKontaktdaten"
    end       
  end


### Mitglieder bearbeiten: Rolle ###
  def editRolle
      if is_allowed(current_user, 20)
        @OZBPerson = OZBPerson.find(current_user.Mnr)
        @Person    = Person.get(@OZBPerson.Mnr)
        
        @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
        @Rollen = @@Rollen
        @Rolle2 = @@Rollen2
            
        @Student         = Student.new
        @Foerdermitglied = Foerdermitglied.new
        @Gesellschafter  = Gesellschafter.new
        @Partner         = Partner.new
        @Mitglied        = Mitglied.new    
        
        case @Person.Rolle
        when "M"
        @Mitglied        = Mitglied.get(@OZBPerson.Mnr)
        when "F"
        @Foerdermitglied = Foerdermitglied.get(@Person.Pnr)
        when "P"
        @Partner         = Partner.get(@OZBPerson.Mnr)
        @PartnerPerson   = Person.get(@Partner.Pnr_P)
        when "G"
        @Gesellschafter  = Gesellschafter.get(@OZBPerson.Mnr)
        when "S"
        @Student         = Student.get(@OZBPerson.Mnr)
        end
      else
        redirect_to "/MeineKonten"
      end
  end

  def updateRolle
    @errors = Array.new                                       
    begin    
     #Beginne Transaktion
      ActiveRecord::Base.transaction do   
          @OZBPerson       = OZBPerson.find(current_user.Mnr)
          @Person          = Person.get(@OZBPerson.Mnr)  
          
          @Rollen          = @@Rollen
          @Rolle2          = @@Rollen2
          @sop_rollen      = @@sop_rollen
          
          @Student         = Student.new
          @Foerdermitglied = Foerdermitglied.new
          @Gesellschafter  = Gesellschafter.new
          @Partner         = Partner.new
          @Mitglied        = Mitglied.new 
        
          case @Person.Rolle
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
            @Student.Abschluss     = params[:abschluss]#
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
                    
        # Weiterleiten
        flash[:notice] = "Rolle wurde erfolgreich aktuallisiert."
        redirect_to :action => "editRolle"
        # render "editRolle"
      end
    # Bei Fehlern Daten reten
    rescue
      @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
      @Rollen           = @@Rollen
      @Rolle2           = @@Rollen2
      render "editRolle"
    end     
  end

### Logindaten bearbeiten ###
  def editLogindaten
    @OZBPerson = OZBPerson.find(current_user)
    @Person    = Person.get(@OZBPerson.Mnr)  
  end

  def updateLogindaten
    
  end

  





  def searchOZBPerson
    super
#    if current_user.Mnr = params[:id] then
#      super
#    else
#      redirect_to "/MeineDaten"
#    end
  end


end
