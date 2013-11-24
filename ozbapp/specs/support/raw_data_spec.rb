require 'spec_helper'
require 'raw_data'

describe RawData do 

	before(:each) do
	 	csv_record = [
	 		"02.11.2012", 
	 		"13.10.2013", 
	 		"U-", 
	 		"808",
	 		"0012-0140 Gutschrift von Hannelore", 
	 		"200", 
	 		"70012", 
	 		"70140"
	 	] 
		@rd = RawData.new(csv_record)
	end



	# #Factory
	# it "has a valid factory" do
	# 	expect(FactoryGirl.create(:raw_data_for_currency_transfer)).to be_valid 
	# end

    it "initializes" do
   	 expect(@rd.instance_variable_get(:@Belegdatum)).to eq 	 "2012-11-02"
   	 expect(@rd.instance_variable_get(:@Buchungsdatum)).to eq "2013-10-13"
   	 expect(@rd.instance_variable_get(:@BelegNrKreis)).to eq  "U-"
   	 expect(@rd.instance_variable_get(:@BelegNr)).to eq 		 808
   	 expect(@rd.instance_variable_get(:@Buchungstext)).to eq  "0012-0140 Gutschrift von Hannelore"
     expect(@rd.instance_variable_get(:@Betrag)).to eq 		 200
   	 expect(@rd.instance_variable_get(:@Sollkonto)).to eq 	 70012
   	 expect(@rd.instance_variable_get(:@Habenkonto)).to eq	 70140
    end


    it "gets the booking year" do
     	expect(@rd.getBookingYear).to eq 2013
	end


	it "gets the credit account lenght" do
     	expect(@rd.getCreditAccountLenght).to eq 5
	end	

	it "gets the credit account lenght" do
     	expect(@rd.getCreditAccountLenght).to eq 5
	end
	

	context "checks the point-lend transcation" do
		it "is a valid point-lend transaction with a cteditor account 88888" do
			@rd.Habenkonto = 88888
     		expect(@rd.isPointsLendTransaction).to eq true
		end		

		it "is an invalid point-lend transaction" do
     		expect(@rd.isPointsLendTransaction).to eq false
		end		

		it "is an invalid point-lend transaction with a debitor account 88888" do
			@rd.Sollkonto = 88888
     		expect(@rd.isPointsLendTransaction).to eq false
		end
	end


	context "the currency transactions check" do
		it "is a valid currency transaction" do
     		expect(@rd.isCurrencyTransaction).to eq true
		end		

		it "is an invalid currency transaction with a creditor account 88888" do
			@rd.Habenkonto = 88888
     		expect(@rd.isCurrencyTransaction).to eq false
		end		

		it "is an invalid currency transaction with a debitor account 88888" do
			@rd.Sollkonto = 88888
     		expect(@rd.isCurrencyTransaction).to eq false
		end		

		it "is an invalid currency transaction with a debitor and creditor account 88888" do
			@rd.Sollkonto = 88888
			@rd.Habenkonto = 88888
     		expect(@rd.isCurrencyTransaction).to eq false
		end
	end



end 