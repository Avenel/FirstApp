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

ActiveRecord::Schema.define(:version => 20111016113940) do

  create_table "administrators", :primary_key => "pnr", :force => true do |t|
    t.string "adminPw",    :limit => 35, :null => false
    t.string "adminEmail"
  end

  create_table "bankverbindungs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buchung_onlines", :force => true do |t|
    t.integer "mnr",         :limit => 10,                :null => false
    t.date    "ueberwdatum",                              :null => false
    t.integer "sollktonr",   :limit => 5,  :default => 0, :null => false
    t.integer "habenktonr",  :limit => 5,  :default => 0, :null => false
    t.integer "punkte",      :limit => 10,                :null => false
    t.integer "tan",         :limit => 5,                 :null => false
    t.integer "blocknr",     :limit => 2,                 :null => false
  end

  create_table "buchungs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buergschafts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ee_kontos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foerdermitglieds", :primary_key => "pnr", :force => true do |t|
    t.string  "region",         :limit => 30
    t.decimal "foerderbeitrag",               :precision => 2, :scale => 5
  end

  create_table "gesellschafters", :primary_key => "mnr", :force => true do |t|
    t.string  "faSteuerNr",        :limit => 15
    t.string  "faLdfNr",           :limit => 20
    t.string  "wohnsitzFinanzamt", :limit => 50
    t.integer "notarPnr",          :limit => 10
    t.date    "beurkDatum"
  end

  create_table "kk_verlaufs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kontenklasses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mitglieds", :primary_key => "mnr", :force => true do |t|
    t.date "rvDatum"
  end

  create_table "ozb_kontos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ozb_people", :primary_key => "mnr", :force => true do |t|
    t.integer "ueberPnr",    :limit => 10
    t.string  "passwort",    :limit => 35
    t.date    "pwAendDatum"
    t.boolean "gesperrt",                  :default => false, :null => false
  end

  create_table "partners", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "people" because of following StandardError
#   Unknown type 'enum' for column 'rolle'

  create_table "projektgruppes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :primary_key => "mnr", :force => true do |t|
    t.string "ausbildBez",    :limit => 30
    t.string "institutName",  :limit => 30
    t.string "studienort",    :limit => 30
    t.date   "studienbeginn"
    t.date   "studienende"
    t.string "abschluss"
  end

  create_table "tanlistes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tans", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teilnahmes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "telefons", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "veranstaltungs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "veranstaltungsarts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ze_kontos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
