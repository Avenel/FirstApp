require 'spec_helper'

describe Waehrung do

	it "has a valid factory" do
		expect(FactoryGirl.create(:Waehrung)).to be_valid
	end

end