require 'spec_helper'

describe Person do

	it "has a valid factory" do
		expect(FactoryGirl.build(:person)).to be_valid
	end

	# TODO
	it "is invalid withot name"

	it "is invalid without firstname"

	it "is invalid without role"

	it "is invalid with an invalid role"

end	