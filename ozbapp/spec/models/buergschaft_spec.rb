require 'spec_helper'

describe Buergschaft do

	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:buergschaft_with_buerge_and_glaeubiger)).to be_valid
	end

end