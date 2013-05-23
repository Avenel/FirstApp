# encoding: UTF-8
class OzbKontoController < ApplicationController
  before_filter :authenticate_OZBPerson!
  before_filter :person_details
  
  # Authorizations for available pages
  before_filter { |c| c.check_authorization_for_action(c) }
  
  # checks if the authorization for the current logged in user is correct to
  # access the requested site.
  #
  # TODO: This should be moved to the application layer
  def check_authorization_for_action(c)
    if ( c.action_name == "index" && !is_allowed(current_OZBPerson, 11)) ||
       ((c.action_name == "new" || c.action_name == "create") && (!is_allowed(current_OZBPerson, 13) && !is_allowed(current_OZBPerson, 15))) ||
       ((c.action_name == "edit" || c.action_name == "update") && (!is_allowed(current_OZBPerson, 14) && !is_allowed(current_OZBPerson, 16))) ||
       ( c.action_name == "delete" && (!is_allowed(current_OZBPerson, 14) && !is_allowed(current_OZBPerson, 16))) ||
       ( c.action_name == "verlauf" && !is_allowed(current_OZBPerson, 11))

        flash[:error] = "Sie haben keine Berechtigung, um diese Seite anzuzeigen."

        # view variables: OZBPerson, Person
        person_details
        
        render "application/access_denied"
    end
  end
  
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
    @ozb_konto         = OzbKonto.new(params[:ozb_konto])
    @ozb_konto.SachPnr = current_OZBPerson.Mnr

    @bankverbindung = Bankverbindung.new
    @bank           = Bank.new
    result          = nil

    if params[:kontotyp] == "EE"    
      @ozb_konto.ee_konto.Bankverbindung.SachPnr = current_OZBPerson.Mnr

      if (!(result = Bankverbindung.find(:first, :conditions => { :Pnr => params[:Mnr] }, :order => "GueltigVon DESC")).nil?)
        @bankverbindung = result

        if (!(result = Bank.find_by_BLZ(@bankverbindung.BLZ)).nil?)
          @bank = result
        end
      end
    end

    if params[:kontotyp] == "ZE"    
      @ozb_konto.ze_konto.SachPnr = current_OZBPerson.Mnr
    end

    if params[:kontotyp] == "EE"    
      @ozb_konto.ee_konto.Bankverbindung.BLZ = params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ]
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
      @ozb_konto.ee_konto.Bankverbindung.SachPnr = current_OZBPerson.Mnr

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
          bank = Bank.find_by_BLZ(params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ])
          
          if (bank.nil?)
            # New Bank
            bank = Bank.new(
              :BLZ      => params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BLZ],
              :BIC      => params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BIC],
              :BankName => params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BankName]
            )
          else
            # Edit Bank
            bank.BIC      = params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BIC]
            bank.BankName = params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:Bank_attributes][:BankName]
          end
          bank.save!
          
          # Bankverbindung NU
          bankverbindung           = @ozb_konto.ee_konto.Bankverbindung
          bankverbindung.BankKtoNr = params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:BankKtoNr]
          bankverbindung.IBAN      = params[:ozb_konto][:ee_konto_attributes][:Bankverbindung_attributes][:IBAN]
          bankverbindung.BLZ       = bank.BLZ
          bankverbindung.Pnr       = bankverbindung.Pnr
          bankverbindung.SachPnr   = current_OZBPerson.Mnr 
          bankverbindung.save!
          
          # EE-Konto NU
          ee             = @ozb_konto.ee_konto
          ee.Kreditlimit = params[:ozb_konto][:ee_konto_attributes][:Kreditlimit]
          ee.SachPnr     = current_OZBPerson.Mnr 
          ee.BankID      = bankverbindung.ID
          # ee.save!
        else
          # ZE-Konto NU
          ze            = @ozb_konto.ze_konto
          ze.EEKtoNr    = params[:ozb_konto][:ze_konto_attributes][:EEKtoNr]
          ze.Pgnr       = params[:ozb_konto][:ze_konto_attributes][:Pgnr]
          ze.ZENr       = params[:ozb_konto][:ze_konto_attributes][:ZENr]
          # ze.ZEAbDatum  = params[:ozb_konto][:ze_konto_attributes][:ZEAbDatum]
          # ze.ZEEndDatum = params[:ozb_konto][:ze_konto_attributes][:ZEEndDatum]
          ze.ZEBetrag   = params[:ozb_konto][:ze_konto_attributes][:ZEBetrag]
          ze.Laufzeit   = params[:ozb_konto][:ze_konto_attributes][:Laufzeit]
          ze.ZahlModus  = params[:ozb_konto][:ze_konto_attributes][:ZahlModus]
          ze.TilgRate   = params[:ozb_konto][:ze_konto_attributes][:TilgRate]
          ze.AnsparRate = params[:ozb_konto][:ze_konto_attributes][:AnsparRate]
          ze.KDURate    = params[:ozb_konto][:ze_konto_attributes][:KDURate]
          ze.RDURate    = params[:ozb_konto][:ze_konto_attributes][:RDURate]
          ze.ZEStatus   = params[:ozb_konto][:ze_konto_attributes][:ZEStatus]
          ze.SachPnr    = current_OZBPerson.Mnr
          
          # ze.save!
        end
      
        #NU
        @ozb_konto.Mnr          = params[:ozb_konto][:Mnr]
        @ozb_konto.Waehrung     = params[:ozb_konto][:Waehrung]
        @ozb_konto.KtoEinrDatum = params[:ozb_konto][:KtoEinrDatum]
        @ozb_konto.SachPnr      = current_OZBPerson.Mnr # for security reasons: no mass-assignment here!
    
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
      @konto.SachPnr    = current_OZBPerson.Mnr
      @konto.save!

      @ozbkonto            = OzbKonto.find_by_KtoNr_and_GueltigBis(params[:KtoNr], "9999-12-31 23:59:59")
      @ozbkonto.GueltigBis = Time.now
      @ozbkonto.SachPnr    = current_OZBPerson.Mnr
      @ozbkonto.save!
      
      flash[:success] = "Konto wurde erfolgreich gelöscht."
    else
      flash[:error] = "Fehler beim Löschen des Kontos."
    end
    
    redirect_to :action => "index"
  end
=begin
  def searchKtoNr
    if current_OZBPerson.canEditB then
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