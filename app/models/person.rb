class Person < ActiveRecord::Base

   set_table_name "Person"

   set_primary_key :pnr  

   attr_accessible   :pnr, :rolle, :name, :vorname, :geburtsdatum, :strasse, :hausnr, :plz, 
                     :ort, :vermerk, :email, :antragsdatum, :aufnahmedatum, :austrittsdatum

   #validates :email, :EmailValidator => true

   has_many :administrator, :foreign_key => :pnr   # Done, getestet
   has_many :telefon, :foreign_key => :pnr         # Done, getestet
   has_many :partner, :foreign_key => :mnr         # Done, benötigt noch ne mitgliedsnummer über OZBPerson
   has_many :teilnahme, :foreign_key => :pnr       # Done, getestet
   has_many :buergschaft, :foreign_key => :pnrB    # Done, getestet
   has_one :ozbperson, :foreign_key => :ueberPnr
   
end

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
