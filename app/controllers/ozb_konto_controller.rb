class OzbKontoController < ApplicationController

  def index
    if current_OZBPerson.canEditB then
      get_konten()
    else
      redirect_to "/"
    end
    
  end
  
  
  def get_konten
    @ozb_konten = OZBKonto.where( :mnr => params[:id] )
    @ee_konten = Array.new
    @ze_konten = Array.new
    
    @ee_count = 0
    @ze_count = 0
    @ozb_konten.each do |konto|
      if konto.EEKonto.count > 0 then
        @ee_konten.push(konto.EEKonto.first)
        @ee_count += 1
      end
      if konto.ZEKonto.count > 0 then
        @ze_konten.push(konto.ZEKonto.first)
        @ze_count += 1
      end
    end
  end
    
  def new
    if current_OZBPerson.canEditB then 
      searchKtoNr()
      @person = Person.where( :pnr => params[:id] ).first
      @ozb_konten = OZBKonto.where( :mnr => params[:id] )
      @ozb_konto = OZBKonto.new

      if params[:typ] == "EE" then      
        count = 0
        @ozb_konten.each do |konto|
          if konto.EEKonto.count > 0 then
            count += 1
          end
        end
       
        # Neue Kontonummer erzeugen
        @newKtoNr = (count + 5).to_s
        (1..(4-@person.pnr.to_s.length)).each do |i|
          @newKtoNr += "0"
        end
        @newKtoNr += @person.pnr.to_s
        
        render "new_ee.html.erb"
      end
      
      if params[:typ] == "ZE" then
        count = 0
        @ozb_konten.each do |konto|
          if konto.ZEKonto.count > 0 then
            count += 1
          end
        end
       
        # Neue Kontonummer erzeugen
        @newKtoNr = (count + 1).to_s
        (1..(4-@person.pnr.to_s.length)).each do |i|
          @newKtoNr += "0"
        end
        @newKtoNr += @person.pnr.to_s
        
        render "new_ze.html.erb"
      end
    else
      redirect_to "/"
    end
  end
  
  def create
    if current_OZBPerson.canEditB then
      @errors = Array.new
      @ozb_konto = OZBKonto.new
      
      # OZB Konto
      # Existiert die Kontonummer bereits?
      kto = OZBKonto.where("ktoNr = ?", params[:ozb_konto][:ktoNr]).first
      ktoEE = EEKonto.where("ktoNr = ?", params[:ozb_konto][:ktoNr]).first
      
      if not(kto.nil? and ktoEE.nil?) then
        error = ActiveModel::Errors.new(@ozb_konto)
        error.add("","Diese Kontonummer ist bereits vergeben.")
        @errors.push(error)
      else
        @ozb_konto = OZBKonto.new(params[:ozb_konto])
        @ozb_konto.ktoEinrDatum = Time.now
        @ozb_konto.waehrung = "EUR"
        @ozb_konto.mnr = params[:id]
        @errors.push(@ozb_konto.validate!)
        
        # Neuen Kontenverlauf hinzufügen
        @verlauf = KKLVerlauf.new( :ktoNr => params[:ozb_konto][:ktoNr], :kklAbDatum => Time.now, :kkl => params[:kkl] )
        @errors.push(@verlauf.validate!)
        
        
        # EE Konto
        if params[:typ] == "EE" then
          # Bankverbindung: id, :pnr, :bankKtoNr, :blz, :bic, :iban, :bankName    
          @bankverbindung = Bankverbindung.new( :pnr => params[:id], :bankKtoNr => params[:bankKtoNr], :blz => params[:blz], :bic => params[:bic], 
                                                   :iban => params[:iban], :bankName => params[:bankName] )
          @errors.push(@bankverbindung.validate!)
          
          # EE-Konto:  :ktoNr, :bankId, :kreditlimit
          @eeKonto = EEKonto.new( :ktoNr => params[:ozb_konto][:ktoNr], :bankId => 1, :kreditlimit => params[:kreditlimit] )
          @errors.push(@eeKonto.validate!)
        end
        
        
        # ZE Konto
        if params[:typ] == "ZE" then
          #ZE-Konto:  :ktoNr, :eeKtoNr, :pgNr, :zeNr, :zeAbDatum, :zeEndDatum, :zeBetrag, :laufzeit, :zahlModus, :tilgRate, :ansparRate, :kduRate, :rduRate, :zeStatus
          @ze_konto = ZEKonto.new( :ktoNr => params[:ozbKtoNr], :eeKtoNr => params[:eeKtoNr], :pgNr => params[:id], :zeNr => params[:zeNr], 
                                      :zeAbDatum => Date.parse(params[:zeAbDatum]), :zeEndDatum => Date.parse(params[:zeEndDatum]), 
                                      :zeBetrag => params[:zeBetrag], :laufzeit => params[:laufzeit], :zahlModus => params[:zahlModus], 
                                      :tilgRate => params[:tilgRate], :ansparRate => params[:ansparRate], :kduRate => params[:kduRate], 
                                      :rduRate => params[:rduRate], :zeStatus => params[:zeStatus] )
          @errors.push(@ze_konto.validate!)
        end
      end
      
      # Auswertung der Validierung
      @error_count = 0
      @errors.each do |error| 
        if !error.nil? && error.any?
          @error_count += error.count 
        end 
      end
      
      if @error_count > 0 then
        if params[:typ] == "EE" then 
          render "new_ee" 
        else
          if params[:typ] == "ZE" then
            render "new_ze"
          else
            redirect_to "/"
          end
        end
        
      else
      
        if params[:typ] == "EE" or params[:typ] == "ZE" then
          @ozb_konto.save
          @verlauf.save
        end
        
        if params[:typ] == "EE" then 
          @bankverbindung.save
          @eeKonto.bankId = @bankverbindung.id
          @eeKonto.save
        end
        
        if params[:typ] == "ZE" then 
          @ze_konto.save
        end
        
        get_konten()
        redirect_to :action => "index", :notice => "Konto erfolgreich angelegt."   
      end
    else
      redirect_to "/"
    end
  end
  
  
  def update
  
  end
  
  
  def save
    
  end
  
  def edit
    if current_OZBPerson.canEditB then 
      searchKtoNr()
      @ozb_konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
      if params[:typ] == "EE" then
        @ee_konto = @ozb_konto.EEKonto.first
        @bankverbindung = Bankverbindung.where( :id => @ee_konto.bankId ).first
        
        render "edit_ee.html.erb"
      end
      
      if params[:typ] == "ZE" then
        @ze_konto = @ozb_konto.ZEKonto.first
        
        render "edit_ze.html.erb"
      end
    else
      redirect_to "/"
    end  
  end
  
  def show
    @ozb_konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
    if params[:typ] == "EE" then
      @konto = @ozb_konto.EEKonto.first
    end
    
    if params[:typ] == "ZE" then
      @konto = @ozb_konto.ZEKonto.first
    end
    
    render "show.html.erb"
  end
  
  def delete
    if current_OZBPerson.canEditB then
      begin
        @konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
        @konto.destroy
        redirect_to :action => "index"
      rescue
      end
    else 
      redirect_to "/"
    end
  end

  def searchKtoNr
    if current_OZBPerson.canEditB then
      if( !params[:ktoNr].nil? ) then
        @konten = OZBKonto.all
      end
      super
    else 
      redirect_to "/"
    end
  end

  # Kümmert sich um die Änderung der Kontenklasse
  def kkl
    if current_OZBPerson.canEditB then
      @konten = OZBKonto.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end
  
  # Ändert die Kontoklasse aller angewählten Konten
  def changeKKL
    if current_OZBPerson.canEditB then
      i = 0
      params[:kkl].each do |kkl|
        @verlauf = KKLVerlauf.create( :ktoNr => params[:ktoNr][i], :kklAbDatum => Time.now, :kkl => kkl )
        i += 1
      end
      redirect_to :action => "kkl"
    else 
      redirect_to "/"
    end
  end

end
