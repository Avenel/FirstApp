require 'spec_helper'

describe OzbKonto do

	#Factory
	it "has a valid factory" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbKonto).to be_valid
	end

end