class Student < ActiveRecord::Base
   
   attr_accessible :mnr, :ausbildBez, :institutName, :studienort, :studienbeginn, :studienende, :abschluss   
   
end
