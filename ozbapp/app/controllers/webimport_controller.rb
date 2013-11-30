#!/bin/env ruby
# encoding: utf-8
class WebimportController < ApplicationController

  before_filter :authenticate_user!

  require "CSVImporter"
  require "Punkteberechnung"
  require "raw_data"


  # constructor
  def initialize
    super
    
    @csv              = CSVImporter.new
    @error            = ""
    @notice           = ""
    @imported_records = 0
    @rows             = 0
    @info             = Array.new
  end

  def index
    render "index"
  end

  def read_status(file)
      @error    = file.error
      @notice   = file.notice
      @rows     = file.rows
  end


  # CSV-File
  def read_csv_file
        uploaded_io = params[:webimport][:file]
        uploaded_disk = Rails.root.join('public', 'uploads', uploaded_io.original_filename)
        
        File.open(uploaded_disk, 'wb') do |file|
          file.write(uploaded_io.read)
        end
        
        # import CSV-File
        @csv.import_from_file(uploaded_disk, ["Belegdatum", "Buchungsdatum", "Belegnummernkreis", "Belegnummer", "Buchungstext", "Buchungsbetrag Euro", "Sollkonto", "Habenkonto"])

        # delete CSV-File
        require 'fileutils'
        FileUtils.rm(uploaded_disk)
  end
  
  def csvimport_buchungen
    if !params[:webimport].nil? && !params[:webimport][:file].nil?

      # read the csv fiel
      self.read_csv_file

      # read satus
      self.read_status(@csv)
      
      collect_konten = Array.new
      @rows.each do |r|
        begin
          ActiveRecord::Base.transaction do
            if r.nil? || r.empty? || r[0].nil?
              next
            end

            
            habenbetrag        = 0.0
            sollbetrag         = 0.0
            typ                = "w"
            belegnummernkreis  = r[2]
            belegnummer        = r[3].to_i
            buchungstext       = r[4].to_s
            sollkontonummer    = r[6].strip.to_i
            habenkontonummer   = r[7].strip.to_i
            buchungsdatum      = Date.strptime(r[0], "%d.%m.%Y").strftime("%Y-%m-%d")
            buchungsjahr       = Date.strptime(r[0], "%d.%m.%Y").strftime("%Y").to_i
            wertstellungsdatum = Date.strptime(r[1], "%d.%m.%Y").strftime("%Y-%m-%d")
            betrag             = (r[5].gsub(/\./, '').gsub(/,/, '.')).to_f
            s                  = r[6].length # Länge Sollkonto
            h                  = r[7].length # Länge Habenkonto

            temp           = buchungstext.split(" ")
            gesellschafter = temp[0]
            
            if (h == 5 || s == 5)
              # Abbuchung-Leihpunkte-Buchung, Storno-Abbuchung-Leihpunkte-Buchung, Punkteüberweisung-Buchung oder Konto-zu-Konto-Buchung
              if (h == 5 && s == 5)
                # Abbuchung-Leihpunkte-Buchung
                if (habenkontonummer == 88888 && sollkontonummer != 88888)

                  # Eine Abbuchung-Leihpunkte-Buchung. Buchung wird in DB eingetragen.
                  temp            = buchungstext.split(" ")
                  temp2           = temp[0].split("-")
                  gesellschafter  = temp2[0]
                  darlehensnummer = temp2[1].to_i
                  typ             = "p"
                  kontonummer     = ZeKonto.find(
                                      :all, 
                                      :conditions => 
                                      { 
                                        :ZENr       => darlehensnummer, 
                                        :GueltigBis => "9999-12-31 23:59:59" 
                                      }
                                    ).first.EEKtoNr
                  sollbetrag      = betrag * (-1.0)
                  
                  b = Buchung.new(
                    :KtoNr        => kontonummer,
                    :BuchJahr     => buchungsjahr,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :BuchDatum    => wertstellungsdatum,
                    :Belegdatum   => buchungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :PSaldoAcc    => 0,
                    :Punkte       => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end 
                  next
                end
                
                # Storno-Abbuchung-Leihpunkte-Buchung
                if (sollkontonummer == 88888 && habenkontonummer != 88888)
                  # Eine Storno-Abbuchung-Leihpunkte-Buchung. Buchung wird in DB eingetragen.
                  temp            = buchungstext.split(" ")
                  temp2           = temp[0].split("-")
                  gesellschafter  = temp2[0]
                  darlehensnummer = temp2[1].to_i
                  typ             = "p"
                  kontonummer     = ZeKonto.find(
                                      :all, 
                                      :conditions => 
                                      { 
                                        :ZENr => darlehensnummer, 
                                        :GueltigBis => "9999-12-31 23:59:59" 
                                      }
                                    ).first.EEKtoNr
                  sollbetrag      = betrag
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                  next
                end
                
                # Punkteüberweisung-Buchung
                if (habenkontonummer.to_s[0] == "8" && sollkontonummer.to_s[0] == "8" && sollkontonummer != 88888 && habenkontonummer != 88888)
                  # Eine Punkteüberweisung-Buchung. Buchung wird in DB eingetragen.
                  logger.debug "##======================================================================"
                  logger.debug "FUND POINTS TRANSACTION"
                  logger.debug "##======================================================================"
                  # Erste Buchung
                  temp         = buchungstext.split(" ")
                  temp2        = temp[0].split("-")
                  kontonummer  = temp2[0].to_i
                  kontonummer2 = temp2[1].to_i
                  sollbetrag   = betrag * (-1.0)
                  typ          = "p"
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                  
                  # Zweite Buchung
                  
                  kontonummer = kontonummer2
                  sollbetrag  = 0.0
                  habenbetrag = betrag
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    # Nur 1x zählen!
                    # imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                  
                  next
                end
                
                # Konto-zu-Konto-Buchung
                if (habenkontonummer.to_s[0]  != "8" && sollkontonummer.to_s[0]  != "8")
                  # Eine Konto-zu-Konto-Buchung.Buchung wird in DB eingetragen.
                  
                  # Erste Buchung
                  kontonummer = sollkontonummer
                  sollbetrag  = betrag
                  habenbetrag = 0.0
                  typ         = "w"
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                  
                  
                  
                  # Zweite Buchung
                  kontonummer = habenkontonummer
                  sollbetrag  = 0.0
                  habenbetrag = betrag
                  typ         = "w"
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )
                  
                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    # Nur 1x zaehlen!
                    #imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end

                  next
                end
              # Gewöhnliche Buchung oder Storno-Buchung
              else
                #TODO PUNKTE STORNO
                
                if (gesellschafter.index("<Storno>") != nil)
                  # wenn Storno-Buchung lösche die entsprechende Buchung aus DB
                  kontonummer = sollkontonummer.to_i
                  
                  b = Buchung.find(
                    :all, 
                    :conditions => 
                    { 
                      :BnKreis    => belegnummernkreis, 
                      :BelegNr    => belegnummer, 
                      :Belegdatum => buchungsdatum, 
                      :KtoNr      => kontonummer 
                    }
                  )

                  b.delete
                  @info << b
                  collect_konten << kontonummer
                  next
                end
                
                # Eine gewöhnliche Buchung. Buchung wird in DB eingetragen.
                if (h == 5)
                  kontonummer = habenkontonummer
                  habenbetrag = betrag
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )

                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                
                  next
                elsif (s == 5)
                  kontonummer = sollkontonummer
                  sollbetrag  = betrag
                  
                  b = Buchung.new(
                    :BuchJahr     => buchungsjahr,
                    :KtoNr        => kontonummer,
                    :BnKreis      => belegnummernkreis,
                    :BelegNr      => belegnummer,
                    :Typ          => typ,
                    :Belegdatum   => buchungsdatum,
                    :BuchDatum    => wertstellungsdatum,
                    :Buchungstext => buchungstext,
                    :Sollbetrag   => sollbetrag,
                    :Habenbetrag  => habenbetrag,
                    :SollKtoNr    => sollkontonummer,
                    :HabenKtoNr   => habenkontonummer,
                    :WSaldoAcc    => 0.0,
                    :Punkte       => 0,
                    :PSaldoAcc    => 0
                  )

                  begin 
                    succ = b.save
                    @info << b
                    logger.debug "##======================================================================"
                    logger.debug succ.to_s
                    logger.debug b.errors.inspect
                    logger.debug "##======================================================================"
                    collect_konten << kontonummer
                    @imported_records += 1
                  rescue Exception => e
                    @error += "Etwas ist schiefgelaufen.<br /><br />"
                    @error += e.message + "<br /><br />"
                  end
                  
                  next
                end
              end
            else
              # Eine FIBU-Buchung wird ignoriert.
            end
          end
        end
      end
      
      # berechnen der Saldo und Punktesaldo für Konten
      if (collect_konten.size == 0 )
        @error += "Keine der zu importierenden Konten in der Datenbank eingetragen"
      else
        collect_konten.uniq.each do |ktoNr|
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
                pkte_acc     = Punkteberechnung.calculate(first_time, second_time, last_saldo_acc, ktoNr)
                end_pkte_acc = end_pkte_acc + pkte_acc
              end
              
              b = Buchung.find(
                :all, 
                :conditions => ["KtoNr = ? AND BelegNr = ? AND BelegDatum = ?", buchung.KtoNr, buchung.BelegNr, buchung.Belegdatum]
              )

              b.each do |bu|
                bu.WSaldoAcc = saldo_acc
                bu.PSaldoAcc = pkte_acc
                bu.Punkte    = end_pkte_acc

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
              
              b = Buchung.find(
                :all, 
                :conditions => ["ktoNr = ? AND belegNr = ? AND belegDatum = ?", buchung.KtoNr, buchung.BelegNr, buchung.Belegdatum]
              )

              b.each do |bu|
                bu.WSaldoAcc = saldo_acc
                bu.PSaldoAcc = 0.00
                bu.Punkte    = end_pkte_acc

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
              konto.WSaldo     = saldo_acc
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
      
      @notice += "<br /><br />" + @csv.number_records.to_s + " von " + @csv.rows.size.to_s + " Datensätzen eingelesen."
      @notice += "<br />" + @imported_records.to_s + " Datensätze importiert."
    else
      @error = "Bitte geben Sie eine CSV-Datei an."
    end

    render "index"
  end
end