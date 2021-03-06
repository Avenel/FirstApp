#!/bin/env ruby
# encoding: utf-8
class WebimportController < ApplicationController

  before_filter :authenticate_user!
  authorize_resource :class => false, :only => [:index]

  require "Punkteberechnung"
  require "CSVImporter"
  require "raw_data"

  # constructor
  def initialize
    super
    
    @error              = ""
    @notice             = ""
    @imported_records   = 0
    @info               = Array.new
    @collected_records  = Array.new
    @failed_records     = Array.new
  end

  def index
    render "index"
  end

  def readCsvFile(uploaded_io)
    csv = CSVImporter.new
    uploaded_disk = Rails.root.join('public', 'uploads', uploaded_io.original_filename)
    
    File.open(uploaded_disk, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    # import CSV-File
    csv.import_from_file(uploaded_disk, ["Belegdatum", "Buchungsdatum", "Belegnummernkreis", "Belegnummer", "Buchungstext", "Buchungsbetrag Euro", "Sollkonto", "Habenkonto"])

    # delete CSV-File
    require 'fileutils'
    FileUtils.rm(uploaded_disk)

    return csv
  end

  def saveTransaction(buchung, skipListingAccount = nil)
    begin 
      buchung.save
      @info << buchung
      @collected_records << buchung.KtoNr

      if skipListingAccount.nil? 
       @imported_records += 1
      end

    rescue Exception => e
      @failed_records << buchung
      @error += "Etwas ist schiefgelaufen.<br /><br />"
      @error += e.message + "<br /><br />"
    end 
  end

  def getOriginalAccountNumber(loanNumber)
    return ZeKonto.find(
                        :all, 
                        :conditions => 
                        { 
                          :ZENr       => loanNumber, 
                          :GueltigBis => "9999-12-31 23:59:59" 
                        }
                      ).first.EEKtoNr
  end

  def debitTrasnaction(transaction, accountNumber = nil, skipListingAccount = nil)
   
    multipicator = 1.0 
    #if no accunt number supplyed
    if accountNumber.nil?
      accountNumber = transaction.getDebitorAccount
    end

    # add a negativ multipicator if its a point transaction
    if transaction.isPonitsTransaction
      multipicator = (-1.0)
    end

    b = Buchung.new(
      :KtoNr        => accountNumber,
      :BuchJahr     => transaction.getBookingYear,
      :BnKreis      => transaction.getRecieptNrRegion,
      :BelegNr      => transaction.getRecieptNr,
      :Typ          => transaction.getType,
      :BuchDatum    => transaction.getTransactionDate,
      :Belegdatum   => transaction.getRecieptDate,
      :Buchungstext => transaction.getText,
      :Sollbetrag   => transaction.getAmount * (multipicator),
      :Habenbetrag  => 0.0,
      :SollKtoNr    => transaction.getDebitorAccount,
      :HabenKtoNr   => transaction.getCreditorAccount,
      :WSaldoAcc    => 0.0,
      :PSaldoAcc    => 0,
      :Punkte       => 0
    )

    self.saveTransaction(b, skipListingAccount)  
  end

  def creaditTransaction(transaction, accountNumber = nil, skipListingAccount = nil)

    #if a loan number is supplyed -> get the original account number from the database
    if accountNumber.nil?
      accountNumber = transaction.getCreditorAccount
    end
    b = Buchung.new(
    :KtoNr        => accountNumber,
    :BuchJahr     => transaction.getBookingYear,
    :BnKreis      => transaction.getRecieptNrRegion,
    :BelegNr      => transaction.getRecieptNr,
    :Typ          => transaction.getType,
    :BuchDatum    => transaction.getTransactionDate,
    :Belegdatum   => transaction.getRecieptDate,
    :Buchungstext => transaction.getText,
    :Sollbetrag   => 0.0,
    :Habenbetrag  => transaction.getAmount,
    :SollKtoNr    => transaction.getDebitorAccount,
    :HabenKtoNr   => transaction.getCreditorAccount,
    :WSaldoAcc    => 0.0,
    :PSaldoAcc    => 0,
    :Punkte       => 0
    )

    self.saveTransaction(b, skipListingAccount)   
  end

  def processTransaction(currentTransaction)
    if currentTransaction.getCreditAccountLenght == 5 || currentTransaction.getDebitAccountLenght == 5
      # => Gewöhnliche Buchung 
      if currentTransaction.getCreditAccountLenght == 5 && currentTransaction.getDebitAccountLenght < 5
        self.creaditTransaction(currentTransaction)
        return
      end

      # => Gewöhnliche Buchung 
      if currentTransaction.getDebitAccountLenght == 5 && currentTransaction.getCreditAccountLenght < 5
        self.debitTrasnaction(currentTransaction)
        return
      end

      # => Abbuchung-Leihpunkte-Buchung
      if currentTransaction.isPointsLendTransaction
        self.debitTrasnaction(currentTransaction, self.getOriginalAccountNumber(currentTransaction.getLoanNumber))
        return
      end
      
      # => Storno-Abbuchung-Leihpunkte-Buchung
      if currentTransaction.isPointsLendStornoTransaction
        self.creaditTransaction(currentTransaction, self.getOriginalAccountNumber(currentTransaction.getLoanNumber))
        return
      end
      
      # => Punkteüberweisung-Buchung
      if currentTransaction.isPonitsTransaction && currentTransaction.getCreditorAccount != 88888 && currentTransaction.getDebitorAccount != 88888
        # Haben Buchung
        self.creaditTransaction(currentTransaction, currentTransaction.getCreditorAccountFromText)
        #Soll Buchung
        self.debitTrasnaction(currentTransaction, currentTransaction.getDebitorAccountFromText)
        return
      end
      
      # Konto-zu-Konto-Buchung
      if currentTransaction.isCurrencyTransaction
        # Eine Konto-zu-Konto-Buchung.Buchung wird in DB eingetragen.              
        self.creaditTransaction(currentTransaction, nil, true)
        self.debitTrasnaction(currentTransaction)
        return
      end
    else
      @failed_records << r
    end
  end

  def reorganizeTransactionData
    @collected_records.uniq.each do |ktoNr|
      b = Buchung.find(
        :all, 
        :conditions => { :KtoNr => ktoNr }, 
        :order => "Belegdatum ASC, Typ DESC, Habenbetrag DESC, Sollbetrag DESC, PSaldoAcc DESC"
      )

      saldo_acc      = 0.0 # wSaldoAcc
      pkte_acc       = 0 # pSaldoAcc
      first_time     = b.first.Belegdatum
      last_saldo_acc = 0.0
      end_pkte_acc   = 0
      last_saldo_data = nil

      # Berechne Daten für die nächste Buchung
      b.each do |buchung|
        if (buchung.Typ == "w")
          second_time = buchung.Belegdatum 

          saldo_acc   = saldo_acc + buchung.Habenbetrag - buchung.Sollbetrag

          if (second_time != first_time)
            pkte_acc     = Punkteberechnung.calculate(first_time.to_time_in_current_zone , second_time.to_time_in_current_zone , last_saldo_acc, ktoNr)
            end_pkte_acc = end_pkte_acc + pkte_acc
          end
          
          b = Buchung.find(
            :all, 
            :conditions => ["KtoNr = ? AND BelegNr = ? AND BelegDatum = ?", buchung.KtoNr, buchung.BelegNr, buchung.Belegdatum]
          )

          b.each do |bu|
            bu.WSaldoAcc = saldo_acc
            bu.PSaldoAcc = end_pkte_acc
            bu.Punkte    = pkte_acc

            begin
              bu.save
            rescue Exception => e
               @error += "Etwas ist schiefgelaufen.<br/><br/>"
               @error += e.message + "<br /><br />"
            end
          end

          first_time      = second_time
          last_saldo_acc  = saldo_acc
          pkte_acc        = 0
          last_saldo_data = buchung.Belegdatum 
        end
        
        if (buchung.Typ == "p")
          end_pkte_acc = end_pkte_acc + buchung.Sollbetrag + buchung.Habenbetrag
          punkte       = buchung.Sollbetrag + buchung.Habenbetrag
          
          b = Buchung.find(
            :all, 
            :conditions => ["KtoNr = ? AND belegNr = ? AND belegDatum = ?", buchung.KtoNr, buchung.BelegNr, buchung.Belegdatum]
          )

          b.each do |bu|
            bu.WSaldoAcc = saldo_acc
            bu.PSaldoAcc = end_pkte_acc
            bu.Punkte    = 0

            begin
               bu.save
            rescue Exception => e
               @error += "Etwas ist schiefgelaufen.<br /><br />"
               @error += e.message + "<br /><br />"
            end
          end
        end

        # das End-Saldo ins Konto eintragen
        konto = OzbKonto.find(:all, :conditions => { :KtoNr => ktoNr }).first
        if (!konto.nil?)
          konto.WSaldo     = last_saldo_acc
          konto.PSaldo     = end_pkte_acc
          konto.SaldoDatum = last_saldo_data 

          begin
            konto.save
          rescue Exception => e
             @error += "Etwas ist schiefgelaufen.<br /><br />"
             @error += e.message + "<br /><br />"
          end
        end
      end
    end
  end

  def csvimport_buchungen
    if !params[:webimport].nil? && !params[:webimport][:file].nil?
      # read the csv file
      csv = self.readCsvFile(params[:webimport][:file])
      # read satus
      @error    = csv.error
      @notice   = csv.notice
      
      csv.rows.each do |r|
        begin
          ActiveRecord::Base.transaction do
            if r.nil? || r.empty? || r[0].nil?
              next
            end
            currentTransaction = RawData.new(r)
            self.processTransaction(currentTransaction);
          end
        end
      end

      # berechnen der Saldo und Punktesaldo für Konten
      if ( @collected_records.size == 0 )
        @error += "Keine der zu importierenden Konten in der Datenbank eingetragen"
      else
        self.reorganizeTransactionData
      end
      
      @notice += "<br /><br />" + csv.number_records.to_s + " von " + csv.rows.size.to_s + " Datensätzen eingelesen."
      @notice += "<br />" + @imported_records.to_s + " Datensätze importiert."
    else
      @error = "Bitte geben Sie eine CSV-Datei an."
    end
    render "index"
  end
end