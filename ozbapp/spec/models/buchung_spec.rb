require 'spec_helper'

describe Buchung do 

	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:buchung_with_ozbkonten)).to be_valid 
	end

	
end