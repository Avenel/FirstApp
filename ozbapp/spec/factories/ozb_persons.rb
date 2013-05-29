require 'faker'

FactoryGirl.define do
	# Creates an OZBPerson with its connected Person Object
	factory :OZBPerson_with_Person, :parent => :Person do

		after_create do |person|
			FactoryGirl.create(:OZBPerson, :Mnr => person)
		end

		sequence(:Mnr) {|n| "#{n}"}
		sequence(:UeberPnr) {|n| "#{n}"} 
		Antragsdatum Time.now
		email {Faker::Internet.email}
		password "helloWorld123"
	end
end