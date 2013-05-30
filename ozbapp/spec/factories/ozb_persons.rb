require 'faker'

FactoryGirl.define do 
	factory :OZBPerson do 
		sequence(:mnr) {|n| "#{n}"}
		sequence(:ueberPnr) {|n| "#{n}"}
		Antragsdatum Time.now
		email {Faker::Internet.email}
		password "helloWorld123"
	end
end