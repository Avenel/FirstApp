class WillkommenController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_user!

  def index
  	# If user admin, check if referer is given and redirect to manage page
  	if !request.referer.nil?

		if (URI(request.referer).path == ('/OZBPerson/Anmeldung') && isUserAdmin(current_user))
			redirect_to '/Verwaltung/Mitglieder'	
		end
		
		if (URI(request.referer).path == ('/OZBPerson/edit') && isUserAdmin(current_user))
			redirect_to '/Verwaltung/Mitglieder'	
		end
	
	end

    @current_person = Person.where("Pnr = ?", current_user.Mnr).first

    @ee_konten = OzbKonto.get_all_ee_for(current_user.id)
    @ze_konten = OzbKonto.get_all_ze_for(current_user.id)
  end
end
