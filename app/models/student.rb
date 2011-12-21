class Student < ActiveRecord::Base
  
  set_table_name "Student"

  attr_accessible :mnr, :ausbildBez, :institutName, :studienort, :studienbeginn, :studienende, :abschluss   
  
  validates_presence_of :ausbildBez, :institutName, :studienort, :studienbeginn, :abschluss
  
  belongs_to :OZBPerson
end
