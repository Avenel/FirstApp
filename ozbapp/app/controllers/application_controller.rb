class ApplicationController < ActionController::Base
  protect_from_forgery


Rails.logger.level = 0
#############NEU20.02.13##################
 
 after_filter :store_location

 def store_location
  session[:previous_url] = request.fullpath unless request.fullpath =~ /\/OZBPerson/
 end

 def after_update_path_for(resource)
 # session[:previous_url] || root_path
  if is_allowed(current_user, 1) then
    "/Verwaltung/Mitglieder"
  else
    "/MeineKonten"
  end
 end
 
 #############ENDE_NEU#############

  ### to get "isCurrentUserInGroup" method available to both controllers and views
  helper_method :isCurrentUserInGroup
  def isCurrentUserInGroup(group)
    return !(Sonderberechtigung.find(:all, :conditions => {:Mnr => current_user.Mnr, :Berechtigung => group})).first.nil?
  end

  helper_method :isCurrentUserAdmin
  def isCurrentUserAdmin
    return !(Sonderberechtigung.find(:all, :conditions => {:Mnr => current_user.Mnr})).first.nil?  
  end
  
  helper_method :getCurrentLocation
  def getCurrentLocation
    return request.path
    #return request.path_parameters['controller']
  end


  helper_method :is_allowed
  def is_allowed(ozb_person, gescheaftsvorfallnr)   
    if ozb_person && ozb_person.Mnr
      if prozess = Geschaeftsprozess.where(:ID => gescheaftsvorfallnr).first
        return true if prozess.IT && Sonderberechtigung.where(:Mnr => ozb_person.Mnr).where(:Berechtigung => "IT").first
        return true if prozess.MV && Sonderberechtigung.where(:Mnr => ozb_person.Mnr).where(:Berechtigung => "MV").first
        return true if prozess.RW && Sonderberechtigung.where(:Mnr => ozb_person.Mnr).where(:Berechtigung => "RW").first
        return true if prozess.ZE && Sonderberechtigung.where(:Mnr => ozb_person.Mnr).where(:Berechtigung => "ZE").first
        return true if prozess.OeA && Sonderberechtigung.where(:Mnr => ozb_person.Mnr).where(:Berechtigung => "OeA").first
      else
        #Kein Prozess mit der id gefunden
        puts "kein Prozess"
      end
    else 
      #Kein gültige OZBPerson angegeben
      puts "kein Person"
    end
    return false
  end



  
  def searchOZBPerson
    #Suchkriterien: mnr, pnr, rolle, name, ktoNr
    @personen = Person.paginate(:page => params[:page], :per_page => 5)
    if params[:sop_mnr].nil? then
      @personen = Person.paginate(:page => params[:page], :per_page => 5)
    else
      if params[:sop_mnr].empty? and params[:sop_name].empty? and 
        params[:sop_ktoNr].empty? and params[:sop_rolle].empty? then
          @personen = Person.paginate(:page => params[:page], :per_page => 5) 
      else
        @personen = Person;
        
        if( !params[:sop_mnr].empty? ) then
          @personen = @personen.where( "pnr like ?", "%" +  params[:sop_mnr] + "%" )
        end
                
        if( !params[:sop_name].empty? or !params[:sop_vorname].empty? ) then
          if !params[:sop_name].empty? and params[:sop_vorname].empty? then
            @personen = Person.where( "(name like ? )", "%" + params[:sop_name] + "%" )
          else
            if !params[:sop_vorname].empty? and params[:sop_name].empty? then
              @personen = Person.where( "(vorname like ? )", "%" + params[:sop_vorname] + "%" )
            else
              @personen = Person.where( "(name like ? AND vorname like ?)", "%" + params[:sop_name] + "%", "%" + params[:sop_vorname] + "%" )
            end
          end
        end
        
        if( !params[:sop_rolle].empty? ) then
          @personen = @personen.where(:rolle => params[:sop_rolle])
        end
        
        if( !params[:sop_ktoNr].empty? ) then
          @konten = OZBKonto.where( "ktoNr LIKE ?", "%" + params[:sop_ktoNr] + "%" )
          
          pnrs = Array.new
          @konten.each do |konto|
            pnrs.push(konto.Mnr)
          end
          
          @personen = @personen.where( " pnr IN (?)", pnrs )
        end
        
        @personen = @personen.paginate(:page => params[:page], :per_page => 5)
      end
    end
  end


  # necessary for paper trail (whodunnit)
  #def info_for_paper_trail
   # { :GueltigBis => Time.now }
  #end

end
