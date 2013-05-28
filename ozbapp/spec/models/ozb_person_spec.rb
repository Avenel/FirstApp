require 'spec_helper'

describe OZBPerson  do	
	it "has a valid factory" do
		ozbPerson = FactoryGirl.create(:OZBPerson)
		expect(ozbPerson).to be_valid

		person = Person.where("id = ?", ozbPerson.UeberPnr)
		expect(person.nil?).to eq false
	end
end