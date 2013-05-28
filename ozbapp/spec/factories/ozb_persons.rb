require 'faker'

FactoryGirl.define do
	# Creates an OZBPerson with its connected Person Object
	factory :OZBPerson do
		Mnr {FactoryGirl.create(:person).pnr}
		UeberPnr :Mnr
		Antragsdatum Time.now
		email {Faker::Internet.email}
		password "helloWorld123"
	end
end