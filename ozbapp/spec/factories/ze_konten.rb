require 'faker'

FactoryGirl.define do

	factory :ZeKonto do
		sequence(:KtoNr) {|n| "#{n}"} 
		sequence(:EEKtoNr) {|n| "#{n}"}
		sequence(:Laufzeit) {|n| "#{n}"}
		sequence(:Pgnr) {|n| "#{n}"}
		sequence(:ZENr) {|n| "D"+(n*10000000).to_s[0, 8]} 
		ZahlModus "m"
		TilgRate 100.00
		NachsparRate 20.00
		KDURate 5.00
		RDURate 5.00
		ZEStatus "a"
		ZEBetrag 42
		Kalk_Leihpunkte 13
		ZEAbDatum Time.now
		ZEEndDatum Time.zone.parse("2050-01-01 23:59:59")

		factory :zeKonto_with_EEKonto_Projektgruppe do
			before(:create) do |zeKonto|
				projektGruppe = FactoryGirl.create(:Projektgruppe)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.EEKtoNr = eeKonto.KtoNr
				zeKonto.Pgnr = projektGruppe.Pgnr
			end
		end


		factory :zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				projektGruppe = FactoryGirl.create(:Projektgruppe)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.KtoNr = ozbKonto.KtoNr
				zeKonto.EEKtoNr = eeKonto.KtoNr
				zeKonto.Pgnr = projektGruppe.Pgnr
			end
		end

		factory :zeKonto_with_ozbKonto_and_EEKonto do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.KtoNr = ozbKonto.KtoNr
				zeKonto.EEKtoNr = eeKonto.KtoNr
			end
		end

		factory :zeKonto_with_ozbKonto_and_Projektgruppe do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				projektGruppe = FactoryGirl.create(:Projektgruppe)

				zeKonto.KtoNr = ozbKonto.KtoNr
				zeKonto.Pgnr = projektGruppe.Pgnr
			end
		end

	end

end