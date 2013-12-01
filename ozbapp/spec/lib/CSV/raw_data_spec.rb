#!/bin/env ruby
# encoding: utf-8
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
   	 expect(@rd.instance_variable_get(:@BelegNr)).to eq 	 808
   	 expect(@rd.instance_variable_get(:@Buchungstext)).to eq "0012-0140 Gutschrift von Hannelore"
     expect(@rd.instance_variable_get(:@Betrag)).to eq 		 200
   	 expect(@rd.instance_variable_get(:@Sollkonto)).to eq 	 70012
   	 expect(@rd.instance_variable_get(:@Habenkonto)).to eq	 70140
    end

    it "gets all data properly" do

     expect(@rd.getRecieptDate).to eq 	 	"2012-11-02"
   	 expect(@rd.getTransactionDate).to eq 	"2013-10-13"
   	 expect(@rd.getRecieptNrRegion).to eq  	"U-"
   	 expect(@rd.getRecieptNr).to eq 		808
   	 expect(@rd.getText).to eq 				"0012-0140 Gutschrift von Hannelore"
     expect(@rd.getAmount).to eq 		 	200
   	 expect(@rd.getCreditorAccount).to eq 	70140
   	 expect(@rd.getDebitorAccount).to eq	70012
    end


    it "gets the booking year" do
     	expect(@rd.getBookingYear).to eq 2013
	end


	it "gets the credit account lenght" do
     	expect(@rd.getCreditAccountLenght).to eq 5
     	@rd.Habenkonto = 1234
		expect(@rd.getCreditAccountLenght).to eq 4
		@rd.Habenkonto = 123
		expect(@rd.getCreditAccountLenght).to eq 3
	end	


	it "gets the debit account lenght" do
     	expect(@rd.getDebitAccountLenght).to eq 5
     	@rd.Sollkonto = 1234
		expect(@rd.getDebitAccountLenght).to eq 4
		@rd.Sollkonto = 123
		expect(@rd.getDebitAccountLenght).to eq 3
	end

	context "getPoints" do
		context "is valid" do
			it "with debitor and creditor accounts starting with an 8" do
			  	@rd.Habenkonto = 81234
				@rd.Sollkonto = 84321
				@rd.Betrag = 123.0
	     		expect(@rd.getPoints).to eq 123
			end
		end
		context "is invalid" do
			it "with debitor and creditor accounts not starint with an 8" do
			  	@rd.Habenkonto = 71234
				@rd.Sollkonto = 74321
				expect(@rd.getPoints).to eq 0
			end
		  	it "with debitor account not starint with an 8" do
			  	@rd.Habenkonto = 81234
				@rd.Sollkonto = 74321
				expect(@rd.getPoints).to eq 0
			end
		  	it "with creditor account not starint with an 8" do
			  	@rd.Habenkonto = 71234
				@rd.Sollkonto = 84321
				expect(@rd.getPoints).to eq 0
			end
		end
	end

	it "get debitor account number from Buchungstext" do
		@rd.Buchungstext = "70140-70013 Überweisung Punkte an Hannelore"
		expect(@rd.getDebitorAccountFromText).to eq 70140	  
	end

	it "get creditor account number from Buchungstext" do
		@rd.Buchungstext = "70140-70013 Überweisung Punkte an Hannelore"
		expect(@rd.getCreditorAccountFromText).to eq 70013	  
	end

	it "get the loan number form the Buchungstext" do
		@rd.Buchungstext = "D70012-60140 Gutschrift von Hannelore"
		expect(@rd.getLoanNumber).to eq 60140	  
	end

	context "getType" do
		context "is a points transaction" do
			it "with a valid points transaction" do
				@rd.Habenkonto = 81234
				@rd.Sollkonto = 84321
		     	expect(@rd.getType).to eq "p"
			end
			it "with a strorno points transaction" do
				@rd.Habenkonto = 81234
				@rd.Sollkonto = 88888
		     	expect(@rd.getType).to eq "p"
			end			
			it "with a points lend transaction" do
				@rd.Habenkonto = 88888
				@rd.Sollkonto = 84321
		     	expect(@rd.getType).to eq "p"
			end
		end
		context "is a currency transaction" do
			it "with a both acount starting with a 7" do
				@rd.Habenkonto = 71234
				@rd.Sollkonto = 74321
		     	expect(@rd.getType).to eq "w"
			end
		end
	end

	context "isPointsLendTransaction" do
		context "is valid" do
			it "is a valid  with a cteditor account 88888 and a debitor account starting with 8" do
				@rd.Habenkonto = 88888
				@rd.Sollkonto = 84321
	     		expect(@rd.isPointsLendTransaction).to eq true
			end		
		end
		context "is invalid" do
			it "is an invalid with creditor and debitor accounts not startin with 8" do
	     		expect(@rd.isPointsLendTransaction).to eq false
			end		

			it "is an invalid with a debitor account 88888 and creditor not starting with 8" do
				@rd.Sollkonto = 88888
	     		expect(@rd.isPointsLendTransaction).to eq false
			end			
			it "is an invalid with a creditor account 88888 and debitor nont starting wiht 8" do
				@rd.Habenkonto = 88888
	     		expect(@rd.isPointsLendTransaction).to eq false
			end
		end
	end


	context "isCurrencyTransaction" do
		context "is valid" do
				it "with valid accounts" do
     		expect(@rd.isCurrencyTransaction).to eq true
			end	
		end
		context "is invalid" do
			it "with a creditor account 88888" do
				@rd.Habenkonto = 88888
	     		expect(@rd.isCurrencyTransaction).to eq false
			end		

			it "with a debitor account 88888" do
				@rd.Sollkonto = 88888
	     		expect(@rd.isCurrencyTransaction).to eq false
			end		

			it "with a debitor and creditor account 88888" do
				@rd.Sollkonto = 88888
				@rd.Habenkonto = 88888
	     		expect(@rd.isCurrencyTransaction).to eq false
			end
		end
	end

	context "isPonitsTransaction" do
		context "is valid" do
			it "with accounts starting with 8 and deffering from an 88888 account" do
	     		@rd.Sollkonto = 81234
				@rd.Habenkonto = 84321
	     		expect(@rd.isPonitsTransaction).to eq true
			end		
		end

		context "is invalid" do
			it "with a debitor account starting with 8 and creditor not starting wiht 8" do
				@rd.Sollkonto = 81234
				@rd.Habenkonto = 74321
	     		expect(@rd.isPonitsTransaction).to eq false
			end

			it "with a creditor account starting with 8 and debitor not starting wiht 8" do
				@rd.Sollkonto = 71234
				@rd.Habenkonto = 84321
	     		expect(@rd.isPonitsTransaction).to eq false
			end
		end
	end


	context "isPointsLendStornoTransaction" do
		context "is valid" do
			it "with accounts starting with 8 and deffering from an 88888 account" do
	     		@rd.Sollkonto = 88888
				@rd.Habenkonto = 84321
	     		expect(@rd.isPointsLendStornoTransaction).to eq true
			end		
		end

		context "is invalid" do
			it "with a creditor account 88888 and a debitor account starting with 7" do
				@rd.Habenkonto = 88888
	     		expect(@rd.isPointsLendStornoTransaction).to eq false
			end		

			it "with a debitor account 88888 and a creditor account starintg with 7" do
				@rd.Sollkonto = 88888
	     		expect(@rd.isPointsLendStornoTransaction).to eq false
			end		

			it "with a debitor and creditor accounts 88888" do
				@rd.Sollkonto = 88888
				@rd.Habenkonto = 88888
	     		expect(@rd.isPointsLendStornoTransaction).to eq false
			end		

			it "with a debitor account starting with 8 and creditor not starting wiht 8" do
				@rd.Sollkonto = 81234
				@rd.Habenkonto = 74321
	     		expect(@rd.isPointsLendStornoTransaction).to eq false
			end

			it "with a creditor account starting with 8 and debitor not starting wiht 8" do
				@rd.Sollkonto = 71234
				@rd.Habenkonto = 84321
	     		expect(@rd.isPointsLendStornoTransaction).to eq false
			end
		end
	end


	context "isStorno" do
		context "is valid" do
			it "with valid currency transaction Buchungstext" do
				@rd.Buchungstext = "<Storno>0140-0005 Überweisung abbruch"
				expect(@rd.isStorno).to eq true
			end			
			it "with valid points transaction Buchungstext" do
				@rd.Sollkonto = 81234
				@rd.Habenkonto = 84321
				@rd.Buchungstext = "<Storno>0140-0120 Überweisungs abbruch"
				expect(@rd.isStorno).to eq true
			end			
		end

		context "is invalid" do
		  it "with no proper storno flag in the Buchungstext" do
		    expect(@rd.isStorno).to eq false
		  end
		end
	end


end 