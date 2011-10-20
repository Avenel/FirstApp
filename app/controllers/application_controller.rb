class ApplicationController < ActionController::Base
  protect_from_forgery
  @@i = 13213
   
  def test
    @person = nil #Person.find(1)
  end
  
end
