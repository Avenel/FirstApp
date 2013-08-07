class Waehrung < ActiveRecord::Base
	self.table_name = "Waherung"
  self.primary_keys = :Code
  
  attr_accessible :Code, :Bezeichnung

  # Validations
  validates :Code, :presence => true, :format => {:with => /[a-zA-Z]{3}/}
  validates :Bezeichnung, :presence => true

end