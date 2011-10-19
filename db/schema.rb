# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111019094830) do

  create_table "Administrator", :primary_key => "pnr", :force => true do |t|
    t.string "adminPw",    :limit => 35, :null => false
    t.string "adminEmail"
  end

  create_table "Bankverbindung", :force => true do |t|
    t.integer "pnr",       :limit => 10, :null => false
    t.string  "bankKtoNr", :limit => 10
    t.integer "blz",       :limit => 10
    t.string  "bic",       :limit => 10
    t.string  "iban",      :limit => 20
    t.string  "bankName",  :limit => 35
  end

  create_table "Buchung", :force => true do |t|
    t.integer "buchJahr",     :limit => 4,                                                  :null => false
    t.integer "ktoNr",        :limit => 5,                                                  :null => false
    t.string  "bnKreis",      :limit => 2,                                                  :null => false
    t.integer "belegNr",      :limit => 10,                                                 :null => false
    t.string  "typ",          :limit => 1,                                                  :null => false
    t.date    "belegDatum",                                                                 :null => false
    t.date    "buchDatum",                                                                  :null => false
    t.string  "buchungstext", :limit => 50,                                                 :null => false
    t.decimal "sollBetrag",                 :precision => 10, :scale => 2
    t.decimal "habenBetrag",                :precision => 10, :scale => 2
    t.integer "sollKtoNr",    :limit => 5,                                 :default => 0,   :null => false
    t.integer "habenKtoNr",   :limit => 5,                                 :default => 0,   :null => false
    t.decimal "wSaldoAcc",                  :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer "punkte",       :limit => 10
    t.integer "pSaldoAcc",    :limit => 10,                                :default => 0,   :null => false
  end

  create_table "BuchungOnline", :force => true do |t|
    t.integer "mnr",         :limit => 10,                :null => false
    t.date    "ueberwdatum",                              :null => false
    t.integer "sollktonr",   :limit => 5,  :default => 0, :null => false
    t.integer "habenktonr",  :limit => 5,  :default => 0, :null => false
    t.integer "punkte",      :limit => 10,                :null => false
    t.integer "tan",         :limit => 5,                 :null => false
    t.integer "blocknr",     :limit => 2,                 :null => false
  end

  create_table "Buergschaft", :force => true do |t|
    t.integer "pnrB",         :limit => 10,                                 :null => false
    t.integer "pnrG",         :limit => 10,                                 :null => false
    t.integer "ktoNr",        :limit => 5,                                  :null => false
    t.date    "sichAbDatum"
    t.date    "sichEndDatum"
    t.decimal "sichBetrag",                  :precision => 10, :scale => 2
    t.string  "sichKurzBez",  :limit => 200
  end

  create_table "EEKonto", :primary_key => "ktoNr", :force => true do |t|
    t.integer "bankId",      :limit => 3
    t.decimal "kreditlimit",              :precision => 5, :scale => 2, :default => 0.0
  end

  create_table "Foerdermitglied", :primary_key => "pnr", :force => true do |t|
    t.string  "region",         :limit => 30
    t.decimal "foerderbeitrag",               :precision => 5, :scale => 2
  end

  create_table "Gesellschafter", :primary_key => "mnr", :force => true do |t|
    t.string  "faSteuerNr",        :limit => 15
    t.string  "faLdfNr",           :limit => 20
    t.string  "wohnsitzFinanzamt", :limit => 50
    t.integer "notarPnr",          :limit => 10
    t.date    "beurkDatum"
  end

  create_table "KKLVerlauf", :force => true do |t|
    t.integer "ktoNr",      :limit => 5, :null => false
    t.date    "kklAbDatum",              :null => false
    t.string  "kkl",        :limit => 1, :null => false
  end

  create_table "Kontenklasse", :primary_key => "kkl", :force => true do |t|
    t.date    "kklAbDatum",                                                :null => false
    t.decimal "prozent",    :precision => 5, :scale => 2, :default => 0.0, :null => false
  end

  create_table "Mitglied", :primary_key => "mnr", :force => true do |t|
    t.date "rvDatum"
  end

  create_table "OZBKonto", :primary_key => "ktoNr", :force => true do |t|
    t.integer "mnr",          :limit => 10,                                                   :null => false
    t.date    "ktoEinrDatum"
    t.string  "waehrung",     :limit => 3,                                 :default => "STR"
    t.decimal "wSaldo",                     :precision => 10, :scale => 2
    t.integer "pSaldo",       :limit => 11
    t.date    "saldoDatum"
  end

  create_table "OZBPerson", :force => true do |t|
    t.integer "ueberPnr",    :limit => 10
    t.string  "passwort",    :limit => 35
    t.date    "pwAendDatum"
    t.boolean "gesperrt",                  :default => false, :null => false
  end

  create_table "Partner", :primary_key => "mnr", :force => true do |t|
    t.integer "mnrO",         :limit => 10, :null => false
    t.string  "berechtigung", :limit => 1,  :null => false
  end

# Could not dump table "Person" because of following StandardError
#   Unknown type 'enum' for column 'rolle'

  create_table "Student", :primary_key => "mnr", :force => true do |t|
    t.string "ausbildBez",    :limit => 30
    t.string "institutName",  :limit => 30
    t.string "studienort",    :limit => 30
    t.date   "studienbeginn"
    t.date   "studienende"
    t.string "abschluss"
  end

# Could not dump table "Tan" because of following StandardError
#   Unknown type 'enum' for column 'status'

# Could not dump table "Tanliste" because of following StandardError
#   Unknown type 'enum' for column 'status'

# Could not dump table "Teilnahme" because of following StandardError
#   Unknown type 'enum' for column 'teilnArt'

  create_table "Telefon", :primary_key => "lfdNr", :force => true do |t|
    t.integer "pnr",        :limit => 10, :null => false
    t.string  "telefonNr",  :limit => 15
    t.string  "telefonTyp", :limit => 6
  end

  create_table "Veranstaltung", :primary_key => "vnr", :force => true do |t|
    t.integer "vid",                   :null => false
    t.date    "vaDatum",               :null => false
    t.string  "vaOrt",   :limit => 30
  end

  create_table "Veranstaltungsart", :force => true do |t|
    t.string "vaBezeichnung", :limit => 30
  end

  create_table "ZEKonto", :primary_key => "ktoNr", :force => true do |t|
    t.integer "eeKtoNr",    :limit => 5,                                                  :null => false
    t.integer "pgNr",       :limit => 2
    t.string  "zeNr",       :limit => 10
    t.date    "zeAbDatum"
    t.date    "zeEndDatum"
    t.decimal "zeBetrag",                 :precision => 10, :scale => 2
    t.integer "laufzeit",   :limit => 4,                                                  :null => false
    t.string  "zahlModus",  :limit => 1,                                 :default => "M"
    t.decimal "tilgRate",                 :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal "ansparRate",               :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal "kduRate",                  :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal "rduRate",                  :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.string  "zeStatus",   :limit => 1,                                 :default => "A", :null => false
  end

  create_table "projektgruppes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
