require 'spec_helper'

describe Ability do
  # Buergschaft
  describe "Buergschaft" do

    # Index
    describe "action index" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, Buergschaft).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, Buergschaft).to be_true
      end

      it "should show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, Buergschaft).to be_true
      end

      it "should show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, Buergschaft).to be_true
      end

      it "should show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, Buergschaft).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :index, Buergschaft).to be_true
      end
    end

    # new, create, delete
    describe "action new, create, delete" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :new, Buergschaft).to be_true
        expect(ability.can? :create, Buergschaft).to be_true
        expect(ability.can? :delete, Buergschaft).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, Buergschaft).to be_true
        expect(ability.cannot? :create, Buergschaft).to be_true
        expect(ability.cannot? :delete, Buergschaft).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, Buergschaft).to be_true
        expect(ability.cannot? :create, Buergschaft).to be_true
        expect(ability.cannot? :delete, Buergschaft).to be_true
      end

      it "should show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :new, Buergschaft).to be_true
        expect(ability.can? :create, Buergschaft).to be_true
        expect(ability.can? :delete, Buergschaft).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, Buergschaft).to be_true
        expect(ability.cannot? :create, Buergschaft).to be_true
        expect(ability.cannot? :delete, Buergschaft).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, Buergschaft).to be_true
        expect(ability.cannot? :create, Buergschaft).to be_true
        expect(ability.cannot? :delete, Buergschaft).to be_true
      end
    end

    # edit, update, updateB
    describe "action edit, update, updateB" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :edit, Buergschaft).to be_true
        expect(ability.can? :update, Buergschaft).to be_true
        expect(ability.can? :updateB, Buergschaft).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, Buergschaft).to be_true
        expect(ability.cannot? :update, Buergschaft).to be_true
        expect(ability.cannot? :updateB, Buergschaft).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, Buergschaft).to be_true
        expect(ability.cannot? :update, Buergschaft).to be_true
        expect(ability.cannot? :updateB, Buergschaft).to be_true
      end

      it "should show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :edit, Buergschaft).to be_true
        expect(ability.can? :update, Buergschaft).to be_true
        expect(ability.can? :updateB, Buergschaft).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, Buergschaft).to be_true
        expect(ability.cannot? :update, Buergschaft).to be_true
        expect(ability.cannot? :updateB, Buergschaft).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, Buergschaft).to be_true
        expect(ability.cannot? :update, Buergschaft).to be_true
        expect(ability.cannot? :updateB, Buergschaft).to be_true
      end
    end

  end

  #OZBKonto
  describe "ozbkonto" do

    # Index, Verlauf
    describe "action index, verlauf" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, OzbKonto).to be_true
        expect(ability.can? :verlauf, OzbKonto).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, OzbKonto).to be_true
        expect(ability.can? :verlauf, OzbKonto).to be_true
      end

      it "should show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, OzbKonto).to be_true
        expect(ability.can? :verlauf, OzbKonto).to be_true
      end

      it "should show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, OzbKonto).to be_true
        expect(ability.can? :verlauf, OzbKonto).to be_true
      end

      it "should show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :index, OzbKonto).to be_true
        expect(ability.can? :verlauf, OzbKonto).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :index, OzbKonto).to be_true
        expect(ability.cannot? :verlauf, OzbKonto).to be_true
      end
    end

    # new, create
    describe "action new, create" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :new, OzbKonto).to be_true
        expect(ability.can? :create, OzbKonto).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, OzbKonto).to be_true
        expect(ability.cannot? :create, OzbKonto).to be_true
      end

      it "should show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :new, OzbKonto).to be_true
        expect(ability.can? :create, OzbKonto).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, OzbKonto).to be_true
        expect(ability.cannot? :create, OzbKonto).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, OzbKonto).to be_true
        expect(ability.cannot? :create, OzbKonto).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :new, OzbKonto).to be_true
        expect(ability.cannot? :create, OzbKonto).to be_true
      end
    end

    # edit, update, delete
    describe "action edit, update, delete" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :edit, OzbKonto).to be_true
        expect(ability.can? :update, OzbKonto).to be_true
        expect(ability.can? :delete, OzbKonto).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, OzbKonto).to be_true
        expect(ability.cannot? :update, OzbKonto).to be_true
        expect(ability.cannot? :delete, OzbKonto).to be_true
      end

      it "should show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :edit, OzbKonto).to be_true
        expect(ability.can? :update, OzbKonto).to be_true
        expect(ability.can? :delete, OzbKonto).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, OzbKonto).to be_true
        expect(ability.cannot? :update, OzbKonto).to be_true
        expect(ability.cannot? :delete, OzbKonto).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, OzbKonto).to be_true
        expect(ability.cannot? :update, OzbKonto).to be_true
        expect(ability.cannot? :delete, OzbKonto).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :edit, OzbKonto).to be_true
        expect(ability.cannot? :update, OzbKonto).to be_true
        expect(ability.cannot? :delete, OzbKonto).to be_true
      end
    end

  end

  #OZBPerson
  describe "ozbperson" do

    # editRolle
    describe "action editRolle" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :editRolle, OZBPerson).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :editRolle, OZBPerson).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editRolle, OZBPerson).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editRolle, OZBPerson).to be_true
      end

      it "should show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :editRolle, OZBPerson).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editRolle, OZBPerson).to be_true
      end
    end
  end

  #Sonderberechtigung
  describe "Sonderberechtigung" do

    # :createBerechtigungRollen, :deleteBerechtigungRollen, :editRollen, :editBerechtigungenRollen, :createSonderberechtigung
    describe "action :createBerechtigungRollen, :deleteBerechtigungRollen, :editRollen, :editBerechtigungenRollen, :createSonderberechtigung" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.can? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.can? :editRollen, Sonderberechtigung).to be_true
        expect(ability.can? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.can? :createSonderberechtigung, Sonderberechtigung).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :createSonderberechtigung, Sonderberechtigung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :createSonderberechtigung, Sonderberechtigung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :createSonderberechtigung, Sonderberechtigung).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :createSonderberechtigung, Sonderberechtigung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :deleteBerechtigungRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :editBerechtigungenRollen, Sonderberechtigung).to be_true
        expect(ability.cannot? :createSonderberechtigung, Sonderberechtigung).to be_true
      end
    end
  end

  # Veranstaltung
  describe "Veranstaltung" do

    # :createDeleteTeilnahme, :createVeranstaltung
    describe "action :createDeleteTeilnahme, :createVeranstaltung" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.can? :createVeranstaltung, Veranstaltung).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.can? :createVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.cannot? :createVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.cannot? :createVeranstaltung, Veranstaltung).to be_true
      end

      it "should show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.can? :createVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :createDeleteTeilnahme, Veranstaltung).to be_true
        expect(ability.cannot? :createVeranstaltung, Veranstaltung).to be_true
      end
    end

    # action :editVeranstaltungen, :newVeranstaltung
    describe "action :editVeranstaltungen, :newVeranstaltung" do
      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.can? :newVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.cannot? :newVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.cannot? :newVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.cannot? :newVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.cannot? :newVeranstaltung, Veranstaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editVeranstaltungen, Veranstaltung).to be_true
        expect(ability.cannot? :newVeranstaltung, Veranstaltung).to be_true
      end
    end
  end

  # :verwaltung
  describe ":verwaltung" do

    # :listOZBPersonen, :detailsOZBPerson
    describe "action :listOZBPersonen, :detailsOZBPerson" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.can? :detailsOZBPerson, :verwaltung).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.can? :detailsOZBPerson, :verwaltung).to be_true
      end

      it "should show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.can? :detailsOZBPerson, :verwaltung).to be_true
      end

      it "should show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.can? :detailsOZBPerson, :verwaltung).to be_true
      end

      it "should show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.can? :detailsOZBPerson, :verwaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :listOZBPersonen, :verwaltung).to be_true
        expect(ability.cannot? :detailsOZBPerson, :verwaltung).to be_true
      end
    end

    # :newOZBPerson, :createOZBPerson, :editPersonaldaten, :updatePersonaldaten, :editKontaktdaten, :updateKontaktdaten, :editRolle, :updateRolle
    describe "action :newOZBPerson, :createOZBPerson, :editPersonaldaten, :updatePersonaldaten, :editKontaktdaten, :updateKontaktdaten, :editRolle, :updateRolle" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :newOZBPerson, :verwaltung).to be_true
        expect(ability.can? :createOZBPerson, :verwaltung).to be_true
        expect(ability.can? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.can? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.can? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.can? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.can? :editRolle, :verwaltung).to be_true
        expect(ability.can? :updateRolle, :verwaltung).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :newOZBPerson, :verwaltung).to be_true
        expect(ability.can? :createOZBPerson, :verwaltung).to be_true
        expect(ability.can? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.can? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.can? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.can? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.can? :editRolle, :verwaltung).to be_true
        expect(ability.can? :updateRolle, :verwaltung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :newOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :createOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :editRolle, :verwaltung).to be_true
        expect(ability.cannot? :updateRolle, :verwaltung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :newOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :createOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :editRolle, :verwaltung).to be_true
        expect(ability.cannot? :updateRolle, :verwaltung).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :newOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :createOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :editRolle, :verwaltung).to be_true
        expect(ability.cannot? :updateRolle, :verwaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :newOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :createOZBPerson, :verwaltung).to be_true
        expect(ability.cannot? :editPersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :updatePersonaldaten, :verwaltung).to be_true
        expect(ability.cannot? :editKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :updateKontaktdaten, :verwaltung).to be_true
        expect(ability.cannot? :editRolle, :verwaltung).to be_true
        expect(ability.cannot? :updateRolle, :verwaltung).to be_true
      end
    end

    # :deleteOZBPerson
    describe "action :deleteOZBPerson" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :deleteOZBPerson, :verwaltung).to be_true
      end

      it "should show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :deleteOZBPerson, :verwaltung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :deleteOZBPerson, :verwaltung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :deleteOZBPerson, :verwaltung).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :deleteOZBPerson, :verwaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :deleteOZBPerson, :verwaltung).to be_true
      end
    end

    # :editBerechtigungen, :createBerechtigung, :deleteBerechtigung
    describe "action :editBerechtigungen, :createBerechtigung, :deleteBerechtigung" do

      it "should show for auth it" do
        user = FactoryGirl.create(:user_auth_it)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.can? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.can? :createBerechtigung, :verwaltung).to be_true
        expect(ability.can? :deleteBerechtigung, :verwaltung).to be_true
      end

      it "should not show for auth mv" do
        user = FactoryGirl.create(:user_auth_mv)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.cannot? :createBerechtigung, :verwaltung).to be_true
        expect(ability.cannot? :deleteBerechtigung, :verwaltung).to be_true
      end

      it "should not show for auth rw" do
        user = FactoryGirl.create(:user_auth_rw)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.cannot? :createBerechtigung, :verwaltung).to be_true
        expect(ability.cannot? :deleteBerechtigung, :verwaltung).to be_true
      end

      it "should not show for auth ze" do
        user = FactoryGirl.create(:user_auth_ze)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.cannot? :createBerechtigung, :verwaltung).to be_true
        expect(ability.cannot? :deleteBerechtigung, :verwaltung).to be_true
      end

      it "should not show for auth oea" do
        user = FactoryGirl.create(:user_auth_oea)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.cannot? :createBerechtigung, :verwaltung).to be_true
        expect(ability.cannot? :deleteBerechtigung, :verwaltung).to be_true
      end

      it "should not show for no auth " do
        user = FactoryGirl.create(:user)
        expect(user).to be_valid
        ability = Ability.new(user)
        expect(ability.cannot? :editBerechtigungen, :verwaltung).to be_true
        expect(ability.cannot? :createBerechtigung, :verwaltung).to be_true
        expect(ability.cannot? :deleteBerechtigung, :verwaltung).to be_true
      end
    end
  end

end