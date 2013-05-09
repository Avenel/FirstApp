# encoding: UTF-8

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "ist ung�ltig")
    end
  end
end

class Sonderberechtigung < ActiveRecord::Base
   self.table_name = "Sonderberechtigung"
   
   alias_attribute :id, :ID   
   alias_attribute :mnr, :Mnr
   alias_attribute :berechtigung, :Berechtigung
   alias_attribute :email, :Email   
         
   set_primary_key :ID
   
   attr_accessible :ID, :Mnr, :Berechtigung, :Email, :SachPnr
   
   belongs_to :OZBPerson, :foreign_key => :Mnr
   
   validates_presence_of :Berechtigung
   validates :email, :presence => true, :email => true
end