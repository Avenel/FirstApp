require 'faker'

FactoryGirl.define do

	factory :Mitglied do
		sequence(:Mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		RVDatum Time.now
		
		factory :mitglied_with_ozbperson do
			before(:create) do |m|
				ozbPerson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				m.Mnr = ozbPerson.Mnr
				m.SachPnr = sachPerson.Mnr
			end
		end
	end

end