class WillkommenController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_OZBPerson!

  def index
	if (URI(request.referer).path == ('/OZBPerson/Anmeldung') && isCurrentUserAdmin)
		redirect_to '/Verwaltung/Mitglieder'	
	end
	
	if (URI(request.referer).path == ('/OZBPerson/edit') && isCurrentUserAdmin)
		redirect_to '/Verwaltung/Mitglieder'	
	end
	
    @current_person = Person.find(:last, :conditions => [ "Pnr = ?", current_OZBPerson.Mnr])
    
    @ee_konten = OzbKonto.get_all_ee_for(current_OZBPerson.Mnr)
    @ze_konten = OzbKonto.get_all_ze_for(current_OZBPerson.Mnr)
  end
end
