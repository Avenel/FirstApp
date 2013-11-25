#!/bin/env ruby
# encoding: utf-8
class RawData

  attr_accessor :Belegdatum, :Buchungsdatum, :BelegNrKreis, :BelegNr, :Buchungstext, :Betrag, :Sollkonto, :Habenkonto

  # constructor
  def initialize(csv_record)
    @Belegdatum     = Date.strptime(csv_record[0], "%d.%m.%Y").strftime("%Y-%m-%d")
    @Buchungsdatum  = Date.strptime(csv_record[1], "%d.%m.%Y").strftime("%Y-%m-%d")
    @BelegNrKreis   = csv_record[2]
    @BelegNr        = csv_record[3].to_i
    @Buchungstext   = csv_record[4].to_s
    @Betrag         = (csv_record[5].gsub(/\./, '').gsub(/,/, '.')).to_f
    @Sollkonto      = csv_record[6].strip.to_i
    @Habenkonto     = csv_record[7].strip.to_i
  end

  def getBookingYear
     return  @Buchungsdatum[0..3].to_i
  end

  def getCreditAccountLenght
    return @Habenkonto.size + 1
  end

  def getDebitAccountLenght
    return @Sollkonto.size + 1
  end

  #todo
  def getPoints
    if self.isPonitsTransaction?
      return @Betrag.to_i
    else
      return 0
    end    
  end

  #todo
  def getLoanNumber
    return @Buchungstext.split(" ")[0].split("-")[1].to_i
  end

  def isPointsLendTransaction
    return @Habenkonto == 88888 && @Sollkonto != 88888 && @Sollkonto.to_s[0] == "8"

  end  

  def isPointsLendStornoTransaction
    return  @Sollkonto == 88888 && @Habenkonto != 88888 && @Habenkonto.to_s[0] == "8" 
  end

  def isPonitsTransaction
    #&& @Sollkonto != 88888 && @Habenkonto != 88888
    return @Habenkonto.to_s[0] == "8" && @Sollkonto.to_s[0] == "8"
  end

  def isCurrencyTransaction
    return @Habenkonto.to_s[0] != "8" && @Sollkonto.to_s[0] != "8"
  end

  def isStorno
    return @Buchungstext.split(" ")[0].split("-")[0].index("<Storno>") != nil
  end



end
