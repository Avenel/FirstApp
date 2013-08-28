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
				buergschaft.Pnr_B = buerge.Pnr
				buergschaft.Mnr_G = glaeubiger.Mnr
			end
		end

		factory :buergschaft_with_buerge_and_glaeubiger_and_zeKonto do
			before(:create) do |buergschaft|
				buerge = FactoryGirl.create(:Person)
				glaeubiger = FactoryGirl.create(:ozbperson_with_person)
				zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)

				buergschaft.Pnr_B = buerge.Pnr
				buergschaft.Mnr_G = glaeubiger.Mnr
				buergschaft.ZENr = zeKonto.ZENr
			end
		end
	end

end