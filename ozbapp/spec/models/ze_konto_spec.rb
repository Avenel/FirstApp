require 'spec_helper'

describe ZeKonto do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe)).to be_valid
	end

	# Valid/invalid attributes

	# Class and instance methods	

end