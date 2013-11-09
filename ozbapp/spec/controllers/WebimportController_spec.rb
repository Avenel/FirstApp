require 'spec_helper'
# require 'webimport_controller'

describe WebimportController do 

	#render index page
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    
end