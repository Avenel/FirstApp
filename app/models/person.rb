class Person < ActiveRecord::Base

   set_table_name "Person"

   set_primary_key :pnr  

   attr_accessible   :pnr, :rolle, :name, :vorname, :geburtsdatum, :strasse, :hausnr, :plz, 
                     :ort, :vermerk, :email, :antragsdatum, :aufnahmedatum, :austrittsdatum
                     
   validates_presence_of :name, :antragsdatum

   #validates :email, :EmailValidator => true

   has_many :administrator, :foreign_key => :pnr, :dependent => :delete_all  # Done, getestet
   has_many :telefon, :foreign_key => :pnr, :dependent => :delete_all         # Done, getestet
   has_many :partner, :foreign_key => :mnrO, :dependent => :delete_all         # Done, getestet
   has_many :teilnahme, :foreign_key => :pnr, :dependent => :delete_all       # Done, getestet
   has_many :buergschaft, :foreign_key => :pnrB, :dependent => :delete_all    # Done, getestet
   has_many :OZBPerson, :foreign_key => :ueberPnr, :dependent => :delete_all # Done, getestet
   has_one :Bankverbindung, :foreign_key => :pnr, :dependent => :destroy # Done, getestet
   has_one :foerdermitglied, :foreign_key => :pnr, :dependent => :destroy
      
end

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
