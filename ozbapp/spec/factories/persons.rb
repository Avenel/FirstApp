require 'faker'

FactoryGirl.define do
	factory :Person do
		sequence(:Pnr) {|n| "#{n}" }
		Name {Faker::Name.first_name}
		Vorname {Faker::Name.last_name}
    SperrKZ false
		Rolle "P"
		EMail {Faker::Internet.email}

		factory :person_with_ozbperson do 
			after(:create) do |person|
				FactoryGirl.create(:OZBPerson, :Mnr => person.Pnr, :UeberPnr => person.Pnr)
			end
		end

	end
end