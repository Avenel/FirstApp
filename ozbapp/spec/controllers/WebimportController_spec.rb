require 'spec_helper'
require 'webimport_controller'
require "CSVImporter"

describe WebimportController do 
	#render index page		
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "initializes" do
     wc = WebimportController.new
   	 expect(wc.instance_variable_get(:@csv)).to be_kind_of(CSVImporter)
   	 expect(wc.instance_variable_get(:@rows)).to eq 0
   	 expect(wc.instance_variable_get(:@row_counter)).to eq 0
   	 expect(wc.instance_variable_get(:@imported_records)).to eq 0
   	 expect(wc.instance_variable_get(:@notice)).to eq ""
   	 expect(wc.instance_variable_get(:@error)).to eq ""
    end

    it "read the status" do 
		file 		= CSVImporter.new
    	file.error 	= "Object Error"
    	file.notice = "Object Notice"
    	file.rows 	= 10

    	wc = WebimportController.new
    	wc.read_status(file)

    	expect(wc.instance_variable_get(:@rows)).to eq file.rows
    	expect(wc.instance_variable_get(:@notice)).to eq file.notice
    	expect(wc.instance_variable_get(:@error)).to eq file.error
    end
end