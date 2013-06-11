require 'faker'

FactoryGirl.define do

	factory :Buergschaft do
		SichAbDatum Time.now
		SichEndDatum Time.zone.parse("2013-12-31")
		sequence(:ZENr) {|n| "D#{n}"} 
		SichBetrag 10000.00

		factory :buergschaft_with_buerge_and_glaeubiger do
			before(:create) do |buergschaft|
				buerge = FactoryGirl.create(:Person)
				glaeubiger = FactoryGirl.create(:ozbperson_with_person)
				buergschaft.Pnr_B = buerge.pnr
				buergschaft.Mnr_G = glaeubiger.mnr
			end
		end
	end

end