# encoding: UTF-8
class Bank < ActiveRecord::Base
  self.table_name = "Bank"
  self.primary_key = :BLZ
  
  alias_attribute :bic, :BIC
  
  validates :BLZ, :numericality => { :only_integer => true }, :uniqueness => true, :presence => { :message => "Bitte geben Sie eine BLZ an." }
  validates :BankName, :presence => { :message => "Bitte geben Sie einen Banknamen an." }
  
  attr_accessible :BLZ, :BIC, :BankName
  
  has_many :Bankverbindung,
    :foreign_key => :BLZ,
    :dependent => :destroy
  
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