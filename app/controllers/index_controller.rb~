class IndexController < ApplicationController
  protect_from_forgery

	before_filter :authenticate_OZBPerson!

  def dashboard
  
    @current_person = Person.find(current_OZBPerson.mnr)
  
  end
  
  def admin
  
  end
  
  def error_404
  
  end

end
