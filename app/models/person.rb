class Person < ActiveRecord::Base

   set_table_name "Person"

   attr_accessible   :pnr, :rolle, :name, :vorname, :geburtsdatum, :strasse, :hausnr, :plz, 
                     :ort, :vermerk, :email, :antragsdatum, :aufnahmedatum, :austrittsdatum

   validates :email, :email => true

   has_many :telefon
   has_many :partner
   has_many :teilnahme
   
   set_primary_key :pnr  

end

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
