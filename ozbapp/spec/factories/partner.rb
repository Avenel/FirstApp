require 'faker'

FactoryGirl.define do

	factory :Partner do
		sequence(:Mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		sequence(:Pnr_P) {|n| "#{n}"}
		Berechtigung "v"
		
		
		factory :partner_with_ozbperson_and_partner do
			before(:create) do |p|
				ozbPerson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				partner = FactoryGirl.create(:Person)
				p.Mnr = ozbPerson.Mnr
				p.Pnr_P = partner.Pnr
				p.SachPnr = sachPerson.Mnr
			end
		end
	end

end