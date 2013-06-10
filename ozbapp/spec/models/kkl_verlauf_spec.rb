require 'spec_helper'

describe KklVerlauf do
	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse)).to be_valid
	end

end
