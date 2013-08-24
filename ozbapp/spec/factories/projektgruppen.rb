require 'faker'

FactoryGirl.define do
	factory :Projektgruppe do
		sequence(:Pgnr) {|n| "#{n}"}
		ProjGruppenBez Faker::Name.name
	end
end