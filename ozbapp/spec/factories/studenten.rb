require 'faker'

FactoryGirl.define do

	factory :Student do
		sequence(:Mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		AusbildBez Faker::Name.title
      	InstitutName Faker::Company.name
      	Studienort Faker::Address.city
      	Studienbeginn Time.zone.parse("2010-01-01")
        Studienende Time.zone.parse("2013-01-01")
        Abschluss Faker::Name.title
		
		factory :student_with_ozbperson do
			before(:create) do |s|
				ozbPerson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				s.Mnr = ozbPerson.Mnr
				s.SachPnr = sachPerson.Mnr
			end
		end
	end

end