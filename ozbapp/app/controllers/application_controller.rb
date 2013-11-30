require "authentication"

class ApplicationController < ActionController::Base
  include Authentication
  protect_from_forgery

  helper_method :is_allowed
  helper_method :isUserAdmin
  helper_method :isUserInGroup


Rails.logger.level = 0
#############NEU20.02.13##################
 
 after_filter :store_location

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Sie haben keine Berechtigung diese Seite anzuzeigen!"
    render "/application/access_denied"
  end 

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
  
  helper_method :getCurrentLocation
  def getCurrentLocation
    return request.path
    #return request.path_parameters['controller']
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
