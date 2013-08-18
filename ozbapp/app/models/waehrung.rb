class Waehrung < ActiveRecord::Base

	self.table_name = "Waherung"
  self.primary_keys = :Code
  
  # attributes
  attr_accessible :Code, :Bezeichnung

  # Validations
  validates :Code, :presence => true, :format => {:with => /[a-zA-Z]{3}/}
  validates :Bezeichnung, :presence => true

  # Associations
  has_many :OZBKonto,
    :primary_key => :Code,
    :foreign_key => :Waehrung

end