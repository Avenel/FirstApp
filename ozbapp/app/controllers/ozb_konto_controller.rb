# encoding: UTF-8
class OzbKontoController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :only => [:index, :new, :create, :edit, :update, :delete, :verlauf]
  before_filter :person_details
  
  def person_details
    @OZBPerson = OZBPerson.find(params[:Mnr])
    @Person = Person.get(@OZBPerson.Mnr)
  end
  
  # done
  def index
    @ee_konten = OzbKonto.get_all_ee_for(@OZBPerson.Mnr)
    @ze_konten = OzbKonto.get_all_ze_for(@OZBPerson.Mnr)
    
    render "index"
  end
  
  # done
  def new
    @action         = "new"
    @ozb_konto      = OzbKonto.new
    @kontotyp       = params[:kontotyp] 
    @bankverbindung = Bankverbindung.new
    @bank           = Bank.new
    result          = nil

    # Gibt es eine bereits bestehende Bankverbindung für diesen Benutzer
    if (!(result = Bankverbindung.find(:first, :conditions => { :Pnr => params[:Mnr] }, :order => "GueltigVon DESC")).nil?)
      @bankverbindung = result

      # Gibt es zu der Bankverbindung auch eine Bank
      if (!(result = Bank.find_by_BLZ(@bankverbindung.BLZ)).nil?)
        @bank = result
      end
    end

    render "new"
  end

  # done
  def create    
    @ozb_konto         = OzbKonto.new
    @ozb_konto.SachPnr = current_user.Mnr
    @ozb_konto.Mnr    = params[:ozb_konto][:Mnr]
    @ozb_konto.KtoNr = params[:ozb_konto][:KtoNr]
    @ozb_konto.KtoEinrDatum = params[:ozb_konto][:KtoEinrDatum]
    @ozb_konto.KklVerlauf_attributes = params[:ozb_konto][:KklVerlauf_attributes]

    if params[:kontotyp] == "ZE"    
      @ozb_konto.ZeKonto_attributes = params[:ozb_konto][:ZeKonto_attributes]
    end

    if params[:kontotyp] == "EE"    
      @ozb_konto.EeKonto_attributes = params[:ozb_konto][:EeKonto_attributes]
    end
    
    @ozb_konto.Waehrung = Waehrung.find(params[:ozb_konto][:WaehrungID])

    @bankverbindung = Bankverbindung.new
    @bank           = Bank.new
    result          = nil

    if params[:kontotyp] == "EE"    
      @ozb_konto.EeKonto.Bankverbindung.SachPnr = current_user.Mnr

      if (!(result = Bankverbindung.find(:first, :conditions => { :Pnr => params[:Mnr] }, :order => "GueltigVon DESC")).nil?)
        @bankverbindung = result

        if (!(result = Bank.find_by_BLZ(@bankverbindung.BLZ)).nil?)
          @bank = result
        end
      end
    end

    if params[:kontotyp] == "ZE"    
      @ozb_konto.ZeKonto.SachPnr = current_user.Mnr
    end

    if params[:kontotyp] == "EE"    
      @ozb_konto.EeKonto.Bankverbindung.BLZ = params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ]
    end

    if (@ozb_konto.save)
      # OK
      flash[:success] = "OZBKonto erfolgreich angelegt."
      
      redirect_to :action => "index"
    else
      # Error
      @action = "new"
      
      @kontotyp =  params[:kontotyp]
      
      render "new"
    end
  end
  
  # done
  def edit
    @action = "edit"
    @ozb_konto = OzbKonto.latest(params[:KtoNr])

    if params[:kontotyp] == "EE"    
      @eekonto = EeKonto.find_by_KtoNr_and_GueltigBis(params[:KtoNr], "9999-12-31 23:59:59")
      @ozb_konto.EeKonto.Bankverbindung.SachPnr = current_user.Mnr

      if (!(result = Bankverbindung.find_by_Pnr_and_ID_and_GueltigBis(params[:Mnr], @eekonto.BankID, "9999-12-31 23:59:59")).nil?)
        @bankverbindung = result

        if (!(result = Bank.find_by_BLZ(@bankverbindung.BLZ)).nil?)
          @bank = result
        end
      end
    end
    
    if (@ozb_konto.nil?)
      flash[:error] = "Dieses Konto existiert leider nicht."
      
      redirect_to :action => "index"
    else
      @kontotyp = params[:kontotyp]
      
      render "edit"
    end
  end
  
  # done, but should be updated in near future to work in a nice and DRY rails way
  def update
    @error = nil
    
    # pickup latest OzbKonto for KtoNr params[:KtoNr]
    @ozb_konto = OzbKonto.latest(params[:KtoNr])
    
    ActiveRecord::Base.transaction do
      begin
        # EE- or ZE-Konto?
        if params[:kontotyp] == "EE"
          # Bank
          bank = Bank.find_by_BLZ(params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ])
          
          if (bank.nil?)
            # New Bank
            bank = Bank.new(
              :BLZ      => params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ],
              :BIC      => params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BIC],
              :BankName => params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BankName]
            )
          else
            # Edit Bank
            bank.BIC      = params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BIC]
            bank.BankName = params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BankName]
          end
          bank.save!
          
          # Bankverbindung NU
          bankverbindung           = @ozb_konto.EeKonto.Bankverbindung
          bankverbindung.BankKtoNr = params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:BankKtoNr]
          bankverbindung.IBAN      = params[:ozb_konto][:EeKonto_attributes][:Bankverbindung_attributes][:IBAN]
          bankverbindung.BLZ       = bank.BLZ
          bankverbindung.Pnr       = bankverbindung.Pnr
          bankverbindung.SachPnr   = current_user.Mnr 
          bankverbindung.save!
          
          # EE-Konto NU
          ee             = @ozb_konto.EeKonto
          ee.Kreditlimit = params[:ozb_konto][:EeKonto_attributes][:Kreditlimit]
          ee.SachPnr     = current_user.Mnr 
          ee.BankID      = bankverbindung.ID
          # ee.save!
        else
          # ZE-Konto NU
          ze            = @ozb_konto.ZeKonto
          ze.EEKtoNr    = params[:ozb_konto][:ze_konto_attributes][:EEKtoNr]
          ze.Pgnr       = params[:ozb_konto][:ze_konto_attributes][:Pgnr]
          ze.ZENr       = params[:ozb_konto][:ze_konto_attributes][:ZENr]
          # ze.ZEAbDatum  = params[:ozb_konto][:ze_konto_attributes][:ZEAbDatum]
          # ze.ZEEndDatum = params[:ozb_konto][:ze_konto_attributes][:ZEEndDatum]
          ze.ZEBetrag   = params[:ozb_konto][:ze_konto_attributes][:ZEBetrag]
          ze.Laufzeit   = params[:ozb_konto][:ze_konto_attributes][:Laufzeit]
          ze.ZahlModus  = params[:ozb_konto][:ze_konto_attributes][:ZahlModus]
          ze.TilgRate   = params[:ozb_konto][:ze_konto_attributes][:TilgRate]
          ze.NachsparRate = params[:ozb_konto][:ze_konto_attributes][:NachsparRate]
          ze.KDURate    = params[:ozb_konto][:ze_konto_attributes][:KDURate]
          ze.RDURate    = params[:ozb_konto][:ze_konto_attributes][:RDURate]
          ze.ZEStatus   = params[:ozb_konto][:ze_konto_attributes][:ZEStatus]
          ze.SachPnr    = current_user.Mnr
          
          # ze.save!
        end
      
        #NU
        @ozb_konto.Mnr          = params[:ozb_konto][:Mnr]
        @ozb_konto.Waehrung     = params[:ozb_konto][:Waehrung]
        @ozb_konto.KtoEinrDatum = params[:ozb_konto][:KtoEinrDatum]
        @ozb_konto.SachPnr      = current_user.Mnr # for security reasons: no mass-assignment here!
    
        # KKL-Verlauf
        # This is manually done because there are some problems with multiple primary keys for KKL-Verlauf!
        if (@ozb_konto.kkl_verlauf.KKL != params[:ozb_konto][:kkl_verlauf_attributes][:KKL])
          kkl = KklVerlauf.new(
            :KtoNr      => @ozb_konto.KtoNr,
            :KKLAbDatum => params[:ozb_konto][:kkl_verlauf_attributes][:KKLAbDatum],
            :KKL        => params[:ozb_konto][:kkl_verlauf_attributes][:KKL]
          )
          kkl.save! # copy! -> extra save
        end
        
        @ozb_konto.save!
      rescue
        @error = "Fehler: Bitte füllen Sie alle Felder korrekt aus."
        raise ActiveRecord::Rollback
      end
    end
    
    if (@error.nil?)
      # OK
      flash[:success] = "OZBKonto erfolgreich aktualisiert."
      
      redirect_to :action => "index"
    else
      # Error
      @action = "edit"
      
      @kontotyp = params[:kontotyp]
      
      render "edit"
    end
  end
=begin
  def show
    @ozb_konto = OZBKonto.where( :ktoNr => params[:ktoNr] ).first
    if params[:typ] == "EE" then
      @konto = @ozb_konto.ee_konto.first
    end
    
    if params[:typ] == "ZE" then
      @konto = @ozb_konto.ze_konto.first
    end
    
    render "show.html.erb"
  end
=end
  
  def delete
    if (params[:kontotyp] == "EE")
      @konto = EeKonto.find_by_KtoNr_and_GueltigBis(params[:KtoNr], "9999-12-31 23:59:59")
    else #params[:kontotyp] == "ZE"
      @konto = ZeKonto.find_by_KtoNr_and_GueltigBis(params[:KtoNr], "9999-12-31 23:59:59")
    end
    
    if (!@konto.nil?)
      @konto.GueltigBis = Time.now
      @konto.SachPnr    = current_user.Mnr
      @konto.save!

      @ozbkonto            = OzbKonto.find_by_KtoNr_and_GueltigBis(params[:KtoNr], "9999-12-31 23:59:59")
      @ozbkonto.GueltigBis = Time.now
      @ozbkonto.SachPnr    = current_user.Mnr
      @ozbkonto.save!
      
      flash[:success] = "Konto wurde erfolgreich gelöscht."
    else
      flash[:error] = "Fehler beim Löschen des Kontos."
    end
    
    redirect_to :action => "index"
  end
=begin
  def searchKtoNr
    if current_user.canEditB then
      if( !params[:ktoNr].nil? ) then
        @konten = OzbKonto.all
      end
      super
    else 
      redirect_to "/"
    end
  end

  # Kümmert sich um die Änderung der Kontenklasse
  def kkl
    if current_user.canEditB then
      @konten = OZBKonto.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end
  
  # Ändert die Kontoklasse aller angewählten Konten
  def changeKKL
    if current_user.canEditB then
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
=end
  # Zeigt den KKLVerlauf an
  def verlauf
    @ozb_konto = OzbKonto.latest(params[:KtoNr])
    
    if (@ozb_konto.nil?)
      flash[:error] = "Dieses Konto existiert leider nicht."
      
      redirect_to :action => "index"
    else
      @verlauf = KklVerlauf.find(:all, :conditions => { :KtoNr => params[:KtoNr] }, :order => "KKLAbDatum ASC")
      
      render "verlauf"
    end
  end
  
  # Shows the account statement for the specified Account.
  # params: Mnr, :KtoNr
  def account_statement
    @ozb_konto = OzbKonto.latest(params[:KtoNr])
    
    if (@ozb_konto.nil?)
      flash[:error] = "Dieses Konto existiert leider nicht."
      
      redirect_to :action => "index"
    else
      render "account_statement"
    end
  end
end