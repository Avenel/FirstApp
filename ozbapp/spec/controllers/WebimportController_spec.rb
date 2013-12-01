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
     expect(wc.instance_variable_get(:@info)).to eq Array.new
     expect(wc.instance_variable_get(:@imported_records)).to eq  0
   	 expect(wc.instance_variable_get(:@collect_konten)).to eq Array.new
    end

  # it "read a csv file" do
    
  #   csv_record = [
  #     "02.11.2012", 
  #     "13.10.2013", 
  #     "U-", 
  #     "808",
  #     "0012-0140 Gutschrift von Hannelore", 
  #     "200", 
  #     "70012", 
  #     "70140"
  #   ] 
  #   wc = WebimportController.new
  #   csv = wc.read_csv_file(csv_record);

  #    expect(csv.rows).to eq 1
  #    expect(csv[0]).to eq "02.11.2012"
  #    expect(csv[1]).to eq "13.10.2013"
  #    expect(csv[2]).to eq "U-"
  #    expect(csv[3]).to eq "808"
  #    expect(csv[4]).to eq "0012-0140 Gutschrift von Hannelore"
  #    expect(csv[5]).to eq "200"
  #    expect(csv[6]).to eq "70012"
  #    expect(csv[7]).to eq "70140"
  # end

  it "gets the correct account number based on a given loannumber" do
   wc = WebimportController.new
   expect(wc.getOriginalAccountNumber("D061215")).to eq 70005
  end

  


end