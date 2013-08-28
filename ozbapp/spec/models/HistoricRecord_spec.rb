require 'spec_helper'
require "HistoricRecord"

# Testclass which implement the historicrecord module, emulates an ActiveRecord class to avoid
# funky tables in database.
class TestHistoricRecordClass 
    include HistoricRecord

    @GueltigBis = nil
    @GueltigVon = nil

    @ID = 0
    
    # Dummy Methods for ActiveRecord attributes or methods
    def GueltigBis
    	return @GueltigBis
    end

    def GueltigBis=(value)
    	@GueltigBis = value
    end


    def GueltigVon
    	return @GueltigVon
    end

    def GueltigVon=(value)
    	@GueltigVon = value
    end

    def ID
      return @ID
    end

    def ID=(value)
      @ID = value
    end

    def copy
      return @@copy
    end

    def copy=(value)
      @@copy = value
    end

    def getLatest
      return self
    end

    def get_primary_keys
      return @id
    end

    def set_primary_keys(value)
      @id = value
    end

    def save(value)
      @ID += 1 
    end

end

describe HistoricRecord do

  # _only_ tests each method for itself.
  # Module Methods

  # set_valid_time
	it "sets the valid time correct, if both (GueltigBis, GueltigVon) equal nil " do
		hr = TestHistoricRecordClass.new
		hr.set_valid_time

    expect(hr.GueltigVon).to eq Time.now
    expect(hr.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")
	end

  it "do not set the valid time correct, if one of them equals nil " do
    hr = TestHistoricRecordClass.new
    hr.GueltigVon = Time.now

    hr.set_valid_time

    expect(hr.GueltigVon).to eq Time.now
    expect(hr.GueltigBis).to eq nil

    hr = TestHistoricRecordClass.new
    hr.GueltigBis = Time.now

    hr.set_valid_time

    expect(hr.GueltigVon).to eq nil
    expect(hr.GueltigBis).to eq Time.now
  end

  it "do not set the valid time correct, if both do not equal nil " do
    hr = TestHistoricRecordClass.new
    hr.GueltigVon = Time.now

    hr.GueltigVon = Time.zone.parse("1337-12-31 23:59:59")
    hr.GueltigBis = Time.zone.parse("1337-12-31 23:59:59")

    hr.set_valid_time

    expect(hr.GueltigVon).to eq Time.zone.parse("1337-12-31 23:59:59")
    expect(hr.GueltigBis).to eq Time.zone.parse("1337-12-31 23:59:59")
  end

  # set_new_valid_time
  it "sets new valid time, if GueltigBis is > 9999-01-01" do
    hr = TestHistoricRecordClass.new
    oldTime = Time.now
    hr.GueltigVon = oldTime
    hr.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")

    sleep(1)
    newTime = Time.now

    hr.set_new_valid_time

    # Expect updated GueltigVon for the new record of hr
    expect(hr.GueltigVon).to eq newTime
    expect(hr.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

    # Expect updated GueltigBis for the new copry record of hr
    expect(hr.copy.GueltigVon).to eq oldTime
    expect(hr.copy.GueltigBis).to eq newTime
  end

  it "do not set new valid time, if GueltigBis < 9999-01-01" do
    hr = TestHistoricRecordClass.new
    oldTime = Time.now
    hr.GueltigVon = oldTime
    hr.GueltigBis = Time.zone.parse("1337-12-31 23:59:59")

    hr.set_new_valid_time

    expect(hr.GueltigVon).to eq oldTime
    expect(hr.GueltigBis).to eq Time.zone.parse("1337-12-31 23:59:59")
  end

  # save_copy
  it "saves copy, if copy of hr record does not equal nil" do
    hr = TestHistoricRecordClass.new
    oldTime = Time.now
    hr.GueltigVon = oldTime
    hr.GueltigBis = Time.zone.parse("1337-12-31 23:59:59")
    hr.ID = 0
    hr.copy = hr

    hr.save_copy

    expect(hr.ID).to eq 1
  end

  it "does not save copy, if copy is nil" do
    hr = TestHistoricRecordClass.new
    oldTime = Time.now
    hr.GueltigVon = oldTime
    hr.GueltigBis = Time.zone.parse("1337-12-31 23:59:59")
    hr.ID = 0
    hr.copy = nil

    hr.save_copy

    expect(hr.ID).to eq 0
  end

  # test all models, which implements the HistoricRecord module
  context "test all models, which implements the HistoricRecord module" do

    # OZBKonto
    it "does historize OZBKonto" do
      # create origin record
      oldTime = Time.now
      ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
      expect(ozbKontoOrigin).to be_valid

      # Asure that only one record exists
      query = OzbKonto.find(:all, :conditions => ["KtoNr = ? AND Mnr = ?", ozbKontoOrigin.KtoNr, ozbKontoOrigin.Mnr])
      expect(query.count).to eq 1

      # Asure GueltigVon and GueltigBis are correct
      expect(ozbKontoOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(ozbKontoOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")

      # Change any value
      ozbKontoOrigin.WSaldo = 42

      # wait a second
      sleep(1)

      # Save
      saveTime = Time.now
      expect(ozbKontoOrigin.save).to eq true

      # Query again, there should be 2 records by now
      query = OzbKonto.find(:all, :conditions => ["KtoNr = ? AND Mnr = ?", ozbKontoOrigin.KtoNr, ozbKontoOrigin.Mnr])
      expect(query.count).to eq 2

      # Check GueltigVon and GueltigBis of both records
      ozbKontoOrigin = OzbKonto.find(:all, :conditions => ["KtoNr = ? AND Mnr = ? AND GueltigBis = ?", 
                                    ozbKontoOrigin.KtoNr, ozbKontoOrigin.Mnr, saveTime]).first
      expect(ozbKontoOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(ozbKontoOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")

      ozbKontoLatest = OzbKonto.find(:all, :conditions => ["KtoNr = ? AND Mnr = ? AND GueltigBis = ?", 
                                    ozbKontoOrigin.KtoNr, ozbKontoOrigin.Mnr, "9999-12-31 23:59:59"]).first
      expect(ozbKontoLatest.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(ozbKontoLatest.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")
    end

    # Person
    it "does historize Person" do
      # create origin record
      oldTime = Time.now
      personOrigin = FactoryGirl.create(:Person)
      expect(personOrigin).to be_valid

      # Asure that only one record exists
      query = Person.find(:all, :conditions => ["Pnr = ?", personOrigin.Pnr])
      expect(query.count).to eq 1

      # Asure GueltigVon and GueltigBis are correct
      expect(personOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(personOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")

      # Change any value
      personOrigin.Vorname = "Hansi4711"

      # wait a second
      sleep(1)

      # Save
      saveTime = Time.now
      expect(personOrigin.save).to eq true

      # Query again, there should be 2 records by now
      query = Person.find(:all, :conditions => ["Pnr = ?", personOrigin.Pnr])
      expect(query.count).to eq 2

      # Check GueltigVon and GueltigBis of both records
      personOrigin = Person.find(:all, :conditions => ["Pnr = ? AND GueltigBis = ?", 
                                    personOrigin.Pnr, saveTime]).first
      expect(personOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(personOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")

      personLatest = Person.find(:all, :conditions => ["Pnr = ? AND GueltigBis = ?", 
                                    personOrigin.Pnr, "9999-12-31 23:59:59"]).first
      expect(personLatest.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(personLatest.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")
    end

    # Adresse
    it "does historize Adresse" do
      # create origin record
      oldTime = Time.now
      adresseOrigin = FactoryGirl.create(:Adresse)
      expect(adresseOrigin).to be_valid

      # Asure that only one record exists
      query = Adresse.find(:all, :conditions => ["Pnr = ?", adresseOrigin.Pnr])
      expect(query.count).to eq 1

      # Asure GueltigVon and GueltigBis are correct
      expect(adresseOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(adresseOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")

      # Change any value
      adresseOrigin.Ort = "Musterstadt42"

      # wait a second
      sleep(1)

      # Save
      saveTime = Time.now
      expect(adresseOrigin.save).to eq true

      # Query again, there should be 2 records by now
      query = Adresse.find(:all, :conditions => ["Pnr = ?", adresseOrigin.Pnr])
      expect(query.count).to eq 2

      # Check GueltigVon and GueltigBis of both records
      adresseOrigin = Adresse.find(:all, :conditions => ["Pnr = ? AND GueltigBis = ?", 
                                    adresseOrigin.Pnr, saveTime]).first
      expect(adresseOrigin.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq oldTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(adresseOrigin.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")

      adresseLatest = Adresse.find(:all, :conditions => ["Pnr = ? AND GueltigBis = ?", 
                                    adresseOrigin.Pnr, "9999-12-31 23:59:59"]).first
      expect(adresseLatest.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq saveTime.getlocal().strftime("%Y-%m-%d %H:%M:%S")
      expect(adresseLatest.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.zone.parse("9999-12-31 23:59:59").getlocal().strftime("%Y-%m-%d %H:%M:%S")
    end

  end

end