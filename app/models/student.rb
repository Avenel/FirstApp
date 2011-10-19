class Student < ActiveRecord::Base
  
  set_table_name "Student"

  attr_accessible :mnr, :ausbildBez, :institutName, :studienort, :studienbeginn, :studienende, :abschluss   
  
  belongs_to :ozbperson
end
