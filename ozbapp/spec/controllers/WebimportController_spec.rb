require 'spec_helper'
require 'raw_data'
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
 	 expect(wc.instance_variable_get(:@notice)).to eq ""
   expect(wc.instance_variable_get(:@error)).to eq ""
   expect(wc.instance_variable_get(:@imported_records)).to eq  0
   expect(wc.instance_variable_get(:@info)).to eq Array.new
 	 expect(wc.instance_variable_get(:@collected_records)).to eq Array.new
  end

  it "gets the correct account number based on a given loannumber" do
   wc = WebimportController.new
   expect(wc.getOriginalAccountNumber("D061215")).to eq 70005
  end
end