require 'faker'

FactoryGirl.define do

	factory :Adresse do
		sequence(:Pnr) { |n| "#{n}"}
		sequence(:SachPnr) { |n| "#{n}"}
		
		Strasse Faker::Address.street_name
		Nr Faker::Address.building_number
		PLZ Faker::Address.zip_code
		Ort Faker::Address.city

		factory :adresse_with_person do
			before(:create) do |address|
				person = FactoryGirl.create(:Person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				address.Pnr = person.Mnr
				address.SachPnr = sachPerson.Mnr
			end
		end
	end

end