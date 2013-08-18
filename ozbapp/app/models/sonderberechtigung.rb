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
  self.primary_key = :ID

  # attributes      
  attr_accessible :ID, :Mnr, :Email, :Berechtigung
   
  # Validations
  validates :Berechtigung, :presence => true
  validates :email, :presence => true, :email => true

   # enum Berechtigung
  AVAILABLE_PERMISSIONS = %W(IT MV RW ZE OeA) 
  validates :Berechtigung, :presence => true, :inclusion => { :in => AVAILABLE_PERMISSIONS, :message => "%{value} is not a valid permission (IT, MV, RW, ZE, OeA)" }  

  # Associations
  belongs_to :OZBPerson, :foreign_key => :Mnr
end