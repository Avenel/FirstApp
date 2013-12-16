module OzbKontoHelper
  
  # builds the relation objects if they're not already assigned via mass-assignment
  def setup_ee_konto(ozb_konto)
    # create new KKLVerlauf to get fields
    if (ozb_konto.KklVerlauf.nil?)
       ozb_konto.build_KklVerlauf  # has_one
    end
    
    # create new EEKonto to get fields
    if (ozb_konto.EeKonto.nil?)
      ozb_konto.build_EeKonto # has_one
    end
    
    # create new Bankverbindung to get fields
    if (ozb_konto.EeKonto.Bankverbindung.nil?)
      ozb_konto.EeKonto.build_Bankverbindung # belongs_to
    end
    
    # create new Bank to get fields
    if (ozb_konto.EeKonto.Bankverbindung.Bank.nil?)
      ozb_konto.EeKonto.Bankverbindung.build_Bank # belongs_to
    end
    
    return ozb_konto
  end
  
  # builds the relation objects if they're not already assigned via mass-assignment
  def setup_ze_konto(ozb_konto)
    # create new KKLVerlauf to get fields
    if (ozb_konto.KklVerlauf.nil?)
       ozb_konto.build_KklVerlauf # has_one
    end
    
    # create new EEKonto to get fields
    if (ozb_konto.ZeKonto.nil?)
      ozb_konto.build_ZeKonto # has_one
    end
    
    return ozb_konto
  end
end
