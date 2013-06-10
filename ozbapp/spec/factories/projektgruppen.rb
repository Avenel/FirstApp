require 'faker'

FactoryGirl.define do
	factory :Projektgruppe do
		sequence(:pgNr) {|n| "#{n}"}
		ProjGruppenBez Faker::Name.name
	end
end