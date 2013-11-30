module Authentication

  def is_allowed(ozb_person, geschaeftsvorfallnr)   
    if ozb_person && ozb_person.Mnr
      prozess = Geschaeftsprozess.where(:ID => geschaeftsvorfallnr).first
      if prozess
        return true if prozess.IT && Sonderberechtigung.where(:Mnr => ozb_person.Mnr, :Berechtigung => "IT").first
        return true if prozess.MV && Sonderberechtigung.where(:Mnr => ozb_person.Mnr, :Berechtigung => "MV").first
        return true if prozess.RW && Sonderberechtigung.where(:Mnr => ozb_person.Mnr, :Berechtigung => "RW").first
        return true if prozess.ZE && Sonderberechtigung.where(:Mnr => ozb_person.Mnr, :Berechtigung => "ZE").first
        return true if prozess.OeA && Sonderberechtigung.where(:Mnr => ozb_person.Mnr, :Berechtigung => "OeA").first
      else
        #Kein Prozess mit der id gefunden
        puts "kein Prozess ID: #{geschaeftsvorfallnr}"
      end
    else 
      #Kein gültige OZBPerson angegeben
      puts "kein Person"
    end
    return false
  end

  def isUserAdmin(user)
    return !(Sonderberechtigung.find(:all, :conditions => {:Mnr => user.Mnr})).first.nil?  
  end

  def isUserInGroup(user, group)
    return !(Sonderberechtigung.find(:all, :conditions => {:Mnr => user.Mnr, :Berechtigung => group})).first.nil?
  end
end