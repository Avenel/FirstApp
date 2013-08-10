# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130810112346) do

  create_table "adresse", :primary_key => "Pnr", :force => true do |t|
    t.datetime "GueltigVon",               :null => false
    t.datetime "GueltigBis",               :null => false
    t.string   "Strasse",    :limit => 50, :null => false
    t.string   "Nr",         :limit => 10
    t.string   "PLZ",        :limit => 10
    t.string   "Ort",        :limit => 20, :null => false
    t.string   "Vermerk",    :limit => 30
    t.integer  "SachPnr"
  end

  create_table "bank", :primary_key => "BLZ", :force => true do |t|
    t.string "BIC",      :limit => 11, :default => "###", :null => false
    t.string "BankName", :limit => 50,                    :null => false
  end

  create_table "bankverbindung", :id => false, :force => true do |t|
    t.integer  "ID",                       :null => false
    t.datetime "GueltigVon",               :null => false
    t.datetime "GueltigBis",               :null => false
    t.integer  "Pnr",                      :null => false
    t.string   "BankKtoNr",  :limit => 20, :null => false
    t.string   "IBAN",       :limit => 22, :null => false
    t.integer  "BLZ",                      :null => false
    t.integer  "SachPnr"
  end

  add_index "bankverbindung", ["BLZ"], :name => "BLZ"

  create_table "buchung", :id => false, :force => true do |t|
    t.integer "BuchJahr",                                                                   :null => false
    t.integer "KtoNr",                                                                      :null => false
    t.string  "BnKreis",      :limit => 2,                                                  :null => false
    t.integer "BelegNr",                                                                    :null => false
    t.string  "Typ",          :limit => 0,                                 :default => "w", :null => false
    t.date    "Belegdatum",                                                                 :null => false
    t.date    "BuchDatum",                                                                  :null => false
    t.string  "Buchungstext", :limit => 50,                                                 :null => false
    t.decimal "Sollbetrag",                 :precision => 10, :scale => 2,                  :null => false
    t.decimal "Habenbetrag",                :precision => 10, :scale => 2,                  :null => false
    t.integer "SollKtoNr",                                                                  :null => false
    t.integer "HabenKtoNr",                                                                 :null => false
    t.decimal "WSaldoAcc",                  :precision => 10, :scale => 2,                  :null => false
    t.integer "Punkte"
    t.integer "PSaldoAcc"
  end

  add_index "buchung", ["KtoNr"], :name => "KtoNr"

  create_table "buchungonline", :primary_key => "ID", :force => true do |t|
    t.integer "Mnr",                         :null => false
    t.date    "UeberwDatum",                 :null => false
    t.integer "SollKtoNr",                   :null => false
    t.integer "HabenKtoNr",                  :null => false
    t.integer "Punkte"
    t.integer "Tan",                         :null => false
    t.integer "BlockNr",     :default => -1, :null => false
  end

  add_index "buchungonline", ["Mnr"], :name => "Mnr"

  create_table "buergschaft", :id => false, :force => true do |t|
    t.integer  "Pnr_B",                                                      :null => false
    t.integer  "Mnr_G",                                                      :null => false
    t.datetime "GueltigVon",                                                 :null => false
    t.datetime "GueltigBis",                                                 :null => false
    t.string   "ZENr",         :limit => 10,                                 :null => false
    t.date     "SichAbDatum",                                                :null => false
    t.date     "SichEndDatum",                                               :null => false
    t.decimal  "SichBetrag",                  :precision => 10, :scale => 2, :null => false
    t.string   "SichKurzbez",  :limit => 200
    t.integer  "SachPnr"
  end

  add_index "buergschaft", ["Mnr_G"], :name => "Mnr_G"

  create_table "eekonto", :id => false, :force => true do |t|
    t.integer  "KtoNr",                                                      :null => false
    t.datetime "GueltigVon",                                                 :null => false
    t.datetime "GueltigBis",                                                 :null => false
    t.integer  "BankID",                                                     :null => false
    t.decimal  "Kreditlimit", :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.integer  "SachPnr"
  end

  create_table "foerdermitglied", :id => false, :force => true do |t|
    t.integer  "Pnr",                                                        :null => false
    t.datetime "GueltigVon",                                                 :null => false
    t.datetime "GueltigBis",                                                 :null => false
    t.string   "Region",         :limit => 30,                               :null => false
    t.decimal  "Foerderbeitrag",               :precision => 5, :scale => 2, :null => false
    t.string   "MJ",             :limit => 0
    t.integer  "SachPnr"
  end

  create_table "geschaeftsprozess", :primary_key => "ID", :force => true do |t|
    t.string  "Beschreibung", :limit => 200, :null => false
    t.boolean "IT",                          :null => false
    t.boolean "MV",                          :null => false
    t.boolean "RW",                          :null => false
    t.boolean "ZE",                          :null => false
    t.boolean "OeA",                         :null => false
  end

  create_table "gesellschafter", :id => false, :force => true do |t|
    t.integer  "Mnr",                             :null => false
    t.datetime "GueltigVon",                      :null => false
    t.datetime "GueltigBis",                      :null => false
    t.integer  "FALfdNr",                         :null => false
    t.string   "FASteuerNr",        :limit => 15, :null => false
    t.string   "FAIdNr",            :limit => 15
    t.string   "Wohnsitzfinanzamt", :limit => 50, :null => false
    t.integer  "NotarPnr"
    t.date     "BeurkDatum"
    t.integer  "SachPnr"
  end

  create_table "kklverlauf", :id => false, :force => true do |t|
    t.integer "KtoNr",                   :null => false
    t.date    "KKLAbDatum",              :null => false
    t.string  "KKL",        :limit => 1, :null => false
  end

  add_index "kklverlauf", ["KKL"], :name => "KKL"

  create_table "kontenklasse", :primary_key => "KKL", :force => true do |t|
    t.date    "KKLEinrDatum",                               :null => false
    t.decimal "Prozent",      :precision => 5, :scale => 2, :null => false
  end

  create_table "mitglied", :id => false, :force => true do |t|
    t.integer  "Mnr",        :null => false
    t.datetime "GueltigVon", :null => false
    t.datetime "GueltigBis", :null => false
    t.date     "RVDatum"
    t.integer  "SachPnr"
  end

  create_table "ozbkonto", :id => false, :force => true do |t|
    t.integer  "KtoNr",                                                    :null => false
    t.datetime "GueltigVon",                                               :null => false
    t.datetime "GueltigBis",                                               :null => false
    t.integer  "Mnr",                                                      :null => false
    t.date     "KtoEinrDatum",                                             :null => false
    t.string   "Waehrung",     :limit => 3,                                :null => false
    t.decimal  "WSaldo",                    :precision => 10, :scale => 2
    t.integer  "PSaldo"
    t.date     "SaldoDatum"
    t.integer  "SachPnr"
  end

  add_index "ozbkonto", ["Mnr"], :name => "Mnr"
  add_index "ozbkonto", ["Waehrung"], :name => "Waehrung"

  create_table "ozbperson", :primary_key => "Mnr", :force => true do |t|
    t.integer  "UeberPnr"
    t.date     "PWAendDatum",                                                                                                       :null => false
    t.date     "Antragsdatum",                                                                                                      :null => false
    t.date     "Aufnahmedatum"
    t.date     "Austrittsdatum"
    t.date     "Schulungsdatum"
    t.integer  "SachPnr"
    t.string   "email",                  :limit => 40,  :default => "test@example.com"
    t.string   "encrypted_password",     :limit => 64,  :default => "$2a$10$qGrVqv4bHcfd4Ld649LoS.xIc/gK8GBdSXAS47AQpg1eVhPQL.H7K", :null => false
    t.string   "reset_password_token",   :limit => 128
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     :limit => 16
    t.string   "last_sign_in_ip",        :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partner", :id => false, :force => true do |t|
    t.integer  "Mnr",                       :null => false
    t.datetime "GueltigVon",                :null => false
    t.datetime "GueltigBis",                :null => false
    t.integer  "Pnr_P",                     :null => false
    t.string   "Berechtigung", :limit => 0
    t.integer  "SachPnr"
  end

  create_table "person", :id => false, :force => true do |t|
    t.integer  "Pnr",                                         :null => false
    t.datetime "GueltigVon",                                  :null => false
    t.datetime "GueltigBis",                                  :null => false
    t.string   "Rolle",        :limit => 0
    t.string   "Name",         :limit => 30,                  :null => false
    t.string   "Vorname",      :limit => 20, :default => "",  :null => false
    t.date     "Geburtsdatum"
    t.string   "EMail"
    t.string   "SperrKZ",      :limit => 0,  :default => "0"
    t.integer  "SachPnr"
  end

  create_table "projektgruppe", :primary_key => "Pgnr", :force => true do |t|
    t.string "ProjGruppenBez", :limit => 50, :null => false
  end

  create_table "sonderberechtigung", :primary_key => "ID", :force => true do |t|
    t.integer "Mnr",                        :null => false
    t.string  "Email",        :limit => 40, :null => false
    t.string  "Berechtigung", :limit => 0,  :null => false
  end

  add_index "sonderberechtigung", ["Mnr"], :name => "Mnr"

  create_table "student", :id => false, :force => true do |t|
    t.integer  "Mnr",                         :null => false
    t.datetime "GueltigVon",                  :null => false
    t.datetime "GueltigBis",                  :null => false
    t.string   "AusbildBez",    :limit => 30, :null => false
    t.string   "InstitutName",  :limit => 30, :null => false
    t.string   "Studienort",    :limit => 30, :null => false
    t.date     "Studienbeginn",               :null => false
    t.date     "Studienende",                 :null => false
    t.string   "Abschluss",     :limit => 20, :null => false
    t.integer  "SachPnr"
  end

  create_table "tan", :id => false, :force => true do |t|
    t.integer "Mnr",                      :null => false
    t.integer "ListNr",                   :null => false
    t.integer "TanNr",                    :null => false
    t.integer "Tan",                      :null => false
    t.date    "VerwendetAm"
    t.string  "Status",      :limit => 0
  end

  create_table "tanliste", :id => false, :force => true do |t|
    t.integer "Mnr",                       :null => false
    t.integer "ListNr",                    :null => false
    t.date    "TanListDatum",              :null => false
    t.string  "Status",       :limit => 0
  end

  create_table "teilnahme", :id => false, :force => true do |t|
    t.integer "Pnr",                   :null => false
    t.integer "Vnr",                   :null => false
    t.string  "TeilnArt", :limit => 0
    t.integer "SachPnr"
  end

  add_index "teilnahme", ["Vnr"], :name => "Vnr"

  create_table "telefon", :id => false, :force => true do |t|
    t.integer "Pnr",                      :null => false
    t.integer "LfdNr",      :limit => 1,  :null => false
    t.string  "TelefonNr",  :limit => 15, :null => false
    t.string  "TelefonTyp", :limit => 0
  end

  create_table "temp", :primary_key => "KtoNr", :force => true do |t|
    t.decimal "Kreditlimit",               :precision => 5, :scale => 2
    t.string  "BankKtoNr",   :limit => 12
    t.integer "BLZ"
    t.string  "BankName",    :limit => 30
  end

  create_table "umlage", :primary_key => "Jahr", :force => true do |t|
    t.decimal "RDU", :precision => 3, :scale => 2, :null => false
    t.decimal "KDU", :precision => 3, :scale => 2, :null => false
  end

  create_table "veranstaltung", :primary_key => "Vnr", :force => true do |t|
    t.integer "VANr",                  :null => false
    t.date    "VADatum",               :null => false
    t.string  "VAOrt",   :limit => 30, :null => false
    t.integer "SachPnr"
  end

  add_index "veranstaltung", ["VANr"], :name => "VANr"

  create_table "veranstaltungsart", :primary_key => "VANr", :force => true do |t|
    t.string "VABezeichnung", :limit => 30, :null => false
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.datetime "GueltigBis"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "waehrung", :primary_key => "Code", :force => true do |t|
    t.string "Bezeichnung", :limit => 30, :null => false
  end

  create_table "zekonto", :id => false, :force => true do |t|
    t.integer  "KtoNr",                                                        :null => false
    t.datetime "GueltigVon",                                                   :null => false
    t.datetime "GueltigBis",                                                   :null => false
    t.integer  "Pgnr",            :limit => 1,                                 :null => false
    t.integer  "EEKtoNr",                                                      :null => false
    t.string   "ZENr",            :limit => 10,                                :null => false
    t.date     "ZEAbDatum",                                                    :null => false
    t.date     "ZEEndDatum",                                                   :null => false
    t.decimal  "ZEBetrag",                      :precision => 10, :scale => 2, :null => false
    t.integer  "Laufzeit",        :limit => 1,                                 :null => false
    t.string   "ZahlModus",       :limit => 0
    t.decimal  "TilgRate",                      :precision => 10, :scale => 2, :null => false
    t.decimal  "NachsparRate",                  :precision => 10, :scale => 2, :null => false
    t.decimal  "KDURate",                       :precision => 10, :scale => 2, :null => false
    t.decimal  "RDURate",                       :precision => 10, :scale => 2, :null => false
    t.string   "ZEStatus",        :limit => 0
    t.integer  "Kalk_Leihpunkte",                                              :null => false
    t.integer  "Tats_Leihpunkte"
    t.string   "Sicherung",       :limit => 50
    t.integer  "SachPnr"
  end

  add_index "zekonto", ["Pgnr"], :name => "Pgnr"

end
