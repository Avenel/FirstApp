# encoding: UTF-8
class BuergschaftController < ApplicationController
  before_filter :authenticate_user!
  
  # Authorizations for available pages
  before_filter { |c| c.check_authorization_for_action(c) }
  before_filter :person_details
  
  # checks if the authorization for the current logged in user is correct to
  # access the requested site.
  #
  # TODO: This should be moved to the application layer
  def check_authorization_for_action(c)
    if (c.action_name == "index" && !is_allowed(current_user, 17)) ||
       (c.action_name == "new" || c.action_name == "create") && !is_allowed(current_user, 18) ||
       (c.action_name == "edit" || c.action_name == "update" || c.action_name == "updateB") && !is_allowed(current_user, 19) ||
       (c.action_name == "delete" && !is_allowed(current_user, 18))

        flash[:error] = "Sie haben keine Berechtigung, um diese Seite anzuzeigen."

        # view variables: OZBPerson, Person
        person_details
        
        render "application/access_denied"
    end
  end
  
  def person_details
    @OZBPerson  = OZBPerson.find(params[:Mnr])
    @Person     = Person.get(@OZBPerson.Mnr)
  end
  
  # done
  def index
    
    # Erhaltene Bürgschaften
    @buergschaftenG = Buergschaft.find(:all, :conditions => ['Pnr_B = ? AND (SichEndDatum > ?) ', params[:Mnr], DateTime.now])
    
    # Vergebene B+ürgschaften
    @buergschaftenB = Buergschaft.find(:all, :conditions => ['Mnr_G = ? AND (SichEndDatum > ?) ', params[:Mnr], DateTime.now])
    
    
    @buergschaftUndOzbKontoG = Array.new
    @buergschaftUndOzbKontoB = Array.new
    
    # Einholung der Zugehörigen Konten und Personen
    @buergschaftenG.each do |buergschaft|
      zeKonto = ZeKonto.find(:first, :conditions => ['ZENr = ?', buergschaft.ZENr])
      erhaltenVonPerson = Person.find(:first, :conditions => ['Pnr = ?', buergschaft.Mnr_G])
      @buergschaftUndOzbKontoG << [buergschaft, zeKonto, erhaltenVonPerson]
    end
    
    @buergschaftenB.each do |buergschaft|
      zeKonto = ZeKonto.find(:first, :conditions => ['ZENr = ?', buergschaft.ZENr])
      erhaltenVonPerson = Person.find(:first, :conditions => ['Pnr = ?', buergschaft.Pnr_B])
      @buergschaftUndOzbKontoB << [buergschaft, zeKonto, erhaltenVonPerson]
    end
    
    @buergschaften  = [@buergschaftUndOzbKontoG, @buergschaftUndOzbKontoB]
    
    @count = 0
    
    @vnr = request.fullpath.split('/')[3] 
    @link_aeltere = "/Verwaltung/OZBPerson/"+@vnr+"/Buergschaften/AeltereBuergschaften" 
   
    render "index"
  end

  #done
  def new
    @action = "new"
    @buergschaft = Buergschaft.new
    @ozbKonten = OzbKonto.find(:all)
    @zeKonten = Array.new
    
    @ozbKonten.each do |ozbkonto|
      
      if @zeKonto = ZeKonto.find(:first, :conditions => {:KtoNr => ozbkonto.KtoNr}) then
        @zeKonten << [ozbkonto, @zeKonto]
      end
      
    end
    
    @url = request.fullpath.split('/')
    @mnr = @url[3]
    @pnr = @url[5]
    render "new"
  end
  
  
  def edit
    @action = "edit"
    @edit ="g"
    @url = request.fullpath.split('/')
    @mnr = @url[3]
    @pnr = @url[5]
    
    @ozbKonten = OzbKonto.find(:all)
    @zeKonten = Array.new
    
    @ozbKonten.each do |ozbkonto|
      
      if @zeKonto = ZeKonto.find(:first, :conditions => {:KtoNr => ozbkonto.KtoNr}) then
        @zeKonten << [ozbkonto, @zeKonto]
      end
      
    end
    
    begin
      @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B= ? AND Mnr_G = ? AND (SichEndDatum >= ? OR SichEndDatum is ?)', params[:Mnr], params[:Pnr_B], DateTime.now, nil])
      
      render "edit"
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Diese Bürgschaft existiert leider nicht."
      redirect_to :action => "index"
    end
  end
  
  
  def editB
    @new_buergschaft = Buergschaft.new
    @action = "edit"
    @edit ="b"
    @url = request.fullpath.split('/')
    @mnr = @url[3]
    @pnr = @url[5]
    
    
    @ozbKonten = OzbKonto.find(:all)
    @zeKonten = Array.new
    
    @ozbKonten.each do |ozbkonto|
      
      if @zeKonto = ZeKonto.find(:first, :conditions => {:KtoNr => ozbkonto.KtoNr}) then
        @zeKonten << [ozbkonto, @zeKonto]
      end
      
    end
    

    begin
      @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B= ? AND Mnr_G = ? AND (SichEndDatum >= ? OR SichEndDatum is ?)', params[:Pnr_B], params[:Mnr], DateTime.now, nil])
      
      render "edit"
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Diese Bürgschaft existiert leider nicht."
      redirect_to :action => "index"
    end
  end
  
  
  def create
    if is_allowed(current_user, 18) then   #Bürgschaft hinzufügen => ändert sich nach der neuen Geschäftsprozesstabelle
   
      @buergschaft = Buergschaft.new(params[:buergschaft])
      
      if !@buergschaft.ZENr.empty?
        @zeKonto = ZeKonto.find(:first, :conditions => {:KtoNr => @buergschaft.ZENr})
        
        @buergschaft.ZENr = @zeKonto.ZENr
      end
      @buergschaft.GueltigVon = @buergschaft.SichAbDatum
      @buergschaft.GueltigBis = @buergschaft.SichEndDatum
      @buergschaft.Mnr_G = @buergschaft.Pnr_B
      @buergschaft.Pnr_B = params[:Mnr]
      
      @buergschaft.SachPnr = current_user.Mnr
     
      
      begin
        @b = Buergschaft.find(:first,:conditions =>['Pnr_B = ? AND Mnr_G = ? AND SichEndDatum > ?', @buergschaft.Pnr_B, @buergschaft.Mnr_G, DateTime.now])
        if ( @b == nil && @buergschaft.save)
          # OK
          flash[:success] = "Bürgschaft erfolgreich angelegt."
          
          redirect_to :action => "index"
          
        elsif (@b != nil) then
          flash[:notice] = "Es besteht bereits eine Bürgschaft mit diesem Bürge."
        else
          # Error
          flash[:error] = "Bürgschaft konnte nicht angelegt werden."
          @action = "new"
          
          redirect_to :action => "new"
        end
      rescue ActiveRecord::RecordNotUnique
        flash[:notice] = "Es besteht bereits eine Bürgschaft mit diesem Bürge."
        
        # Error
        @action = "new"
        
        redirect_to :action => "new"
      end
    end    
  end
  
  
  def update
    if is_allowed(current_user, 19) then   #Bürgschaft bearbeiten => ändert sich nach neuer Geschäftsprozesstabelle
      if params[:art] =="g" then
          @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B = ? AND Mnr_G = ? AND (SichEndDatum >= ? OR SichEndDatum is ?)', params[:Mnr],params[:Pnr_B], DateTime.now, nil])
        else
          @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B = ? AND Mnr_G = ? AND (SichEndDatum >= ? OR SichEndDatum is ?)', params[:Pnr_B], params[:Mnr], DateTime.now, nil])
      end
      
      
      @new_buergschaft = @buergschaft.dup
      @new_buergschaft.Pnr_B = @buergschaft.Pnr_B
      @new_buergschaft.Mnr_G = @buergschaft.Mnr_G
      @new_buergschaft.ZENr = @buergschaft.ZENr
      @new_buergschaft.GueltigBis = @buergschaft.SichEndDatum
      @new_buergschaft.GueltigVon = @buergschaft.SichAbDatum
      @new_buergschaft.SichAbDatum = @buergschaft.SichAbDatum
      @new_buergschaft.SichEndDatum = DateTime.now
      @new_buergschaft.SichKurzbez = @buergschaft.SichKurzbez
      @new_buergschaft.SachPnr = @buergschaft.SachPnr
  
      
      
      begin
        
        if (@new_buergschaft.save && @buergschaft.update_attributes(params[:buergschaft]))
          # OK
          flash[:success] = "Bürgschaft erfolgreich aktualisiert."
          redirect_to :action => "index"
        else
          # Error
          @action = "edit"
          render "edit"
        end
      rescue
        flash[:error] = "Diese Bürgschaft existiert leider nicht mehr."
        redirect_to :action => "index"
      end
    end 
  end
  
  
  def delete
    if params[:art] == "g" then
      @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B = ? AND Mnr_G = ? AND SichEndDatum >= ?', params[:Mnr],params[:Pnr_B], DateTime.now])
    else
      @buergschaft = Buergschaft.find(:first, :conditions => ['Pnr_B = ? AND Mnr_G = ? AND SichEndDatum >= ?', params[:Pnr_B], params[:Mnr], DateTime.now])
    end
    
    if (@buergschaft.update_attributes(:SichEndDatum => DateTime.now))
      # OK
      flash[:success] = "Bürgschaft erfolgreich gelöscht."
    else
      # Error
      flash[:error] = "Bürgschaft wurde nicht gelöscht."
    end
    
    redirect_to :action => "index"
  end
  
  
  def listHisto
    @buergschaftenG = Buergschaft.find(:all, :conditions => ['Mnr_G = ?', params[:Mnr]], :order => :SichAbDatum)
    @buergschaftenB = Buergschaft.find(:all, :conditions => ['Pnr_B = ?', params[:Mnr]], :order => :SichAbDatum)
  
    
    @buergschaftUndOzbKontoG = Array.new
    @buergschaftUndOzbKontoB = Array.new
    
    @buergschaftenG.each do |buergschaft|
      zeKonto = ZeKonto.find(:first, :conditions => ['ZENr = ?', buergschaft.ZENr])
      erhaltenVonPerson = Person.find(:first, :conditions => ['Pnr = ?', buergschaft.Pnr_B])
      @buergschaftUndOzbKontoG << [buergschaft, zeKonto, erhaltenVonPerson]
    end
    
    @buergschaftenB.each do |buergschaft|
      zeKonto = ZeKonto.find(:first, :conditions => ['ZENr = ?', buergschaft.ZENr])
      erhaltenVonPerson = Person.find(:first, :conditions => ['Pnr = ?', buergschaft.Mnr_G])
      @buergschaftUndOzbKontoB << [buergschaft, zeKonto, erhaltenVonPerson]
    end
    
    @buergschaften = [@buergschaftUndOzbKontoB, @buergschaftUndOzbKontoG]
    
    @count = 0

  end
  
  def dynamic_districts
    @districts = OzbKonto.get_all_ee_for(params[:id])
 
    respond_to do |format|
      format.js           
    end
end
  
  
  

end
