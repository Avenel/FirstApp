require 'spec_helper'

describe Bankverbindung do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person)).to be_valid
	end
end
