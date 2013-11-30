require 'faker'

FactoryGirl.define do
	sequence :gen_pnr do |x|
    "#{x+200}"
  end

	factory :Person do
		Pnr { FactoryGirl.generate(:gen_pnr) }
		Name {Faker::Name.first_name}
		Vorname {Faker::Name.last_name}
    SperrKZ false
		Rolle "P"
		EMail { Faker::Internet.email }
	end

	factory :person_with_ozbperson, :parent => :Person do 
		after(:create) do |person|
			FactoryGirl.create(:OZBPerson, :Mnr => person.Pnr, :UeberPnr => person.Pnr)
		end
	end

end