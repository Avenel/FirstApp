# encoding: UTF-8
class Bank < ActiveRecord::Base
  self.table_name = "Bank"
  self.primary_key = :BLZ
  
  attr_accessible :BLZ, :BIC, :BankName

  has_many :Bankverbindung,
    :foreign_key => :BLZ,
    :dependent => :destroy

  # Validations
  validates :BLZ, :uniqueness => true, :presence => true, :format => { :with => /^[0-9]{8}$/i, :message => "Bitte geben Sie eine valide BLZ an." }
  validates :BankName, :presence => { :message => "Bitte geben Sie einen Banknamen an." }
  
  validate :valid_BIC

  def valid_BIC 
    if self.BIC.nil? or self.BIC.match(/(^.{8}$)|(^.{11}$)/i) then
      return true
    else
      errors.add :BIC, "Bitte geben Sie eine valide BIC an."
      return false
    end
  end
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :BLZ      => 'BLZ',
    :BIC      => 'BIC',
    :BankName => 'Name der Bank'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # is called from Bankverbindung when it's deleted and
  # checks if the last Bankverbindung was deleted that corresponds to a
  # lonely Bank object. The function destroys the record if
  # it's a record without any children.
  def self.destroy_yourself_if_you_are_alone(blz)
    b = Bank.find(blz)
      
    if !b.nil?
      # check if there are any more Bankverbindungen
      # if not -> delete
      # otherwise -> do not delete
      if b.Bankverbindung.count == 0
        b.destroy
      end
    end
  end
end