#!/bin/env ruby
# encoding: utf-8
class CSVImporter
  require 'iconv'
  require 'csv'
  
  attr_accessor :processed, :number_records, :error, :notice, :cols, :rows
  
  # constructor
  def initialize
    @processed      = false
    @number_records = 0
    @error          = ""
    @notice         = ""
    @cols           = []
    @rows           = []
  end

  # @cols = (Array) Spaltennamen (sortiert nach Index)
  # @rows = (Array) Zeilen in passender Reihenfolge zu @cols
  def import_from_file(file, cols_to_import)
    # Vordefinierte Spalten. Reihenfolge muss mit Quelldatei übereinstimmen! (case insensitive)
    def_cols = cols_to_import
    def_map = {} # Hashmap für Zuweisung von Spaltenname -> Index in row
    
    # Encoding aller Zeichen vom ursprünglichen Encoding nach UTF-8
    i = Iconv.new('UTF-8', 'LATIN1')
    
    utf8_encoded_file = ""
    file = File.new(file, "r")
    while (line = file.gets)
      utf8_encoded_file += i.iconv(line)
    end
    file.close
    
    @rows = Array.new
    n = -1
    begin
      # try
      CSV.parse(utf8_encoded_file, :col_sep => ";") do |row|
        n += 1
        if n == 0
          # Erster Durchlauf = Spaltennamen
          col_headers = row
          
          # Case insensitive
          # col_headers.map!{ |i|
          #   i.downcase if !i.nil?
          # }.uniq
          
          # Überprüfe, ob alle Spalten vorhanden sind
          not_included = Array.new
          col_pos      = 0
          def_cols.each do |dc|
            if (!col_headers.include?(dc))
              # enthält die Spalte dc nicht
              not_included.push(dc)
            else
              # enthält die Spalte dc an Position col_pos
              def_map[dc] = col_pos
            end
            
            col_pos += 1
          end
          
          if (not_included.size > 0)
            @error = "Folgende Spalten sind nicht vorhanden: " + not_included.join(", ")
            break
          end
          
          # Sortiere Hashmap
          @cols = def_map.sort_by{ |key, value| value }.to_a
        else 
          # Zweiter..n-ter Durchlauf = Daten
          a = Array.new
          def_cols.each do |dc|
            a << row[def_map[dc]]
          end
          @rows.push(a)
        end
      end
    rescue CSV::IllegalFormatError => e
      # catch
      @error = "Ungültige Datei (#{e.class})"
    else
      # final
      if n == @rows.size
        # done -> wenn alle Zeilen abgelaufen wurden
        @processed      = true
        @number_records = n
        @notice         = "Folgende Spalten wurden aus der Datei verwendet: " + def_cols.join(", ")
      end
    end
  end
end