# encoding: UTF-8
class Bank < ActiveRecord::Base
  
  self.table_name = "Bank"
  self.primary_key = :BLZ
  
  attr_accessible :BLZ, :BIC, :BankName

  # column names
  HUMANIZED_ATTRIBUTES = {
    :BLZ      => 'BLZ',
    :BIC      => 'BIC',
    :BankName => 'Name der Bank'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :BLZ, :uniqueness => true, :presence => true, :format => { :with => /^[0-9]{8}$/i, :message => "Bitte geben Sie eine valide BLZ an." }
  validates :BankName, :presence => true
  validates :BIC, :uniqueness => true, :presence => true, :format => { :with => /(^.{8}$)|(^.{11}$)/i, :message => "Bitte geben Sie eine valide BIC an." }

  # Relations
  has_many :Bankverbindung,
    :foreign_key => :BLZ,
    :dependent => :restrict

end