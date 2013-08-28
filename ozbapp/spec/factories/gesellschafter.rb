require 'faker'

FactoryGirl.define do

	factory :Gesellschafter do
		sequence(:Mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		sequence(:FALfdNr) {|n| "#{n}"}
  		sequence(:FASteuerNr) {|n| "#{n}"}
		Wohnsitzfinanzamt Faker::Address.city
		
		factory :gesellschafter_with_ozbperson do
			before(:create) do |gs|
				ozbPerson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				gs.Mnr = ozbPerson.Mnr
				gs.SachPnr = sachPerson.Mnr
			end
		end
	end

end