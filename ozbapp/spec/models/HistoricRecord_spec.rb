require 'spec_helper'
require "HistoricRecord"

# This spec _only_ tests each method for itself.

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

end