class OzbKontoController < ApplicationController

  def index
  
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
  
    if params[:typ] == "EE" then
      @person = Person.where( :pnr => params[:id] ).first
      @ozb_konten = OZBKonto.where( :mnr => params[:id] )
      
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
  
  end
  
  def save
  
    if params[:typ] == "EE" then
      # Editieren
      begin
        @ozb_konto = OZBKonto.where( :ktoNr => params[:ozbKtoNr] ).first
        @ee_konto = @ozb_konto.EEKonto.first
        @bankverbindung = Bankverbindung.where( :id => @ee_konto.bankId ).first
        
        @ee_konto.kreditlimit = params[:kreditlimit]
        @ee_konto.save
        
        @bankverbindung.bankKtoNr = params[:bankKtoNr]
        @bankverbindung.bankName = params[:bankName]
        @bankverbindung.blz = params[:blz]
        @bankverbindung.bic = params[:bic]
        @bankverbindung.iban = params[:iban]
        @bankverbindung.save
        
      rescue
        # Neu anlegen
        # OZB-Konto:  :ktoNr, :mnr, :ktoEinrDatum, :waehrung, :wSaldo, :pSaldo, :saldoDatum
        @ozb_konto = OZBKonto.create( :ktoNr => params[:ozbKtoNr], :mnr => params[:id], :ktoEinrDatum => params[:ktoEinrDatum],
                                     :waehrung => "EUR", :wSaldo => params[:wSaldo], :pSaldo => params[:pSaldo], :saldoDatum => params[:saldoDatum] )
        @ozb_konto.save
        
        # Bankverbindung: id, :pnr, :bankKtoNr, :blz, :bic, :iban, :bankName    
        @bankverbindung = Bankverbindung.create( :pnr => params[:id], :bankKtoNr => params[:bankKtoNr], :blz => params[:blz], :bic => params[:bic], :iban => params[:iban],
                                                 :bankName => params[:bankName] )
        @bankverbindung.save
        
        # EE-Konto:  :ktoNr, :bankId, :kreditlimit
        @eeKonto = EEKonto.create( :ktoNr => params[:ozbKtoNr], :bankId => @bankverbindung.id, :kreditlimit => params[:kreditlimit] )
        @eeKonto.save
      end
      
      redirect_to :action => "index"
    end
  
  end
  
  def edit
  
    if params[:typ] == "EE" then
      @ozb_konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
      @ee_konto = @ozb_konto.EEKonto.first
      @bankverbindung = Bankverbindung.where( :id => @ee_konto.bankId ).first
      
      render "edit_ee.html.erb"
    end
  
  end
  
  def delete
    #begin
      @konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
      puts @konto.inspect
      @konto.delete
      redirect_to :action => "index"
    #rescue
    #end
    
  end

end
