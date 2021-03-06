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


  def getRecieptDate
    return @Belegdatum
  end

  def getTransactionDate
    return @Buchungsdatum
  end

  def getRecieptNrRegion
    return @BelegNrKreis
  end

  def getRecieptNr
    return @BelegNr
  end

  def getText
    return @Buchungstext 
  end

  def getAmount
    return @Betrag
  end

  def getDebitorAccount
    return @Sollkonto
  end

  def getCreditorAccount
    return @Habenkonto
  end

  def getBookingYear
     return  @Buchungsdatum[0..3].to_i
  end

  def getCreditAccountLenght
    return @Habenkonto.to_s.size
  end

  def getDebitAccountLenght
    return @Sollkonto.to_s.size
  end

  def getDebitorAccountFromText
    return @Buchungstext.split(" ")[0].split("-")[0].to_i
  end

  def getCreditorAccountFromText
    return @Buchungstext.split(" ")[0].split("-")[1].to_i
  end

  def getPoints
    if self.isPonitsTransaction
      return @Betrag.to_i
    else
      return 0
    end    
  end

  def getType
    if self.isPonitsTransaction
      return "p"
    else
      return "w"
    end
  end

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
    return @Habenkonto.to_s[0] == "8" && @Sollkonto.to_s[0] == "8"
  end

  def isCurrencyTransaction
    return @Habenkonto.to_s[0] != "8" && @Sollkonto.to_s[0] != "8"
  end
end
