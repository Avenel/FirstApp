require 'faker'

FactoryGirl.define do

	factory :Foerdermitglied do
		sequence(:Pnr) { |n| "#{n}"}
		sequence(:SachPnr) { |n| "#{n}"}
		Region Faker::Address.city
		Foerderbeitrag 4200
		MJ "m"

		factory :foerdermitglied_with_person do
			before(:create) do |fm|
				person = FactoryGirl.create(:Person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				fm.Pnr = person.Pnr
				fm.SachPnr = sachPerson.Mnr
			end
		end
	end

end